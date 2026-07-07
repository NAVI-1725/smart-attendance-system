# code.py
"""
AI Code Exporter Pro
A professional desktop utility for exporting source code in AI-friendly formats.
Single-file Python application using only standard library.
"""
 
import os
import json
import shutil
import tkinter as tk
from tkinter import ttk, scrolledtext, filedialog, messagebox
from datetime import datetime
from pathlib import Path
import threading
import queue
import hashlib
import math
 
 
# ─────────────────────────────────────────────────────────────────────────────
# CONSTANTS
# ─────────────────────────────────────────────────────────────────────────────
 
APP_NAME = "AI Code Exporter Pro"
CONFIG_FILE = "config.json"
LOG_FILE = "export_log.txt"
 
IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".gif", ".bmp", ".webp", ".ico", ".svg", ".tiff", ".tif"}
BINARY_EXTENSIONS = {
    ".exe", ".dll", ".so", ".class", ".jar",
    ".zip", ".rar", ".7z", ".tar", ".gz", ".bz2",
    ".mp3", ".mp4", ".mov", ".avi", ".mkv", ".wmv",
    ".pdf", ".pyc", ".pyo", ".pyd", ".db", ".sqlite",
    ".bin", ".dat", ".o", ".a", ".lib", ".wasm",
}
 
AI_PRESETS = {
    "Claude":    {"tokens": 150000, "label": "Claude (~150k tokens)"},
    "ChatGPT":   {"tokens": 30000,  "label": "ChatGPT (~30k tokens)"},
    "Gemini":    {"tokens": 100000, "label": "Gemini (~100k tokens)"},
    "Cursor":    {"tokens": 50000,  "label": "Cursor (~50k tokens)"},
    "Windsurf":  {"tokens": 50000,  "label": "Windsurf (~50k tokens)"},
    "Generic":   {"tokens": 25000,  "label": "Generic (~25k tokens)"},
}
 
DARK_THEME = {
    "bg":       "#1E1E2E",
    "fg":       "#EAEAEA",
    "panel":    "#252538",
    "textbox":  "#2D2D44",
    "accent":   "#5B8CFF",
    "success":  "#50C878",
    "warning":  "#FFB347",
    "error":    "#FF6B6B",
    "border":   "#3A3A55",
    "select":   "#3D3D5C",
    "muted":    "#888AAA",
    "button":   "#2D2D44",
    "btn_hover":"#3A3A5C",
}
 
LIGHT_THEME = {
    "bg":       "#F5F7FA",
    "fg":       "#222222",
    "panel":    "#FFFFFF",
    "textbox":  "#FAFAFA",
    "accent":   "#4F7DFF",
    "success":  "#50C878",
    "warning":  "#E07B00",
    "error":    "#D93025",
    "border":   "#DADDE8",
    "select":   "#E0E8FF",
    "muted":    "#777799",
    "button":   "#EAECF5",
    "btn_hover":"#D8DCEE",
}
 
DEFAULT_CONFIG = {
    "last_root_directory": "",
    "theme": "dark",
    "chunk_tokens": 25000,
    "ai_preset": "Generic",
    "skip_git": True,
    "skip_node_modules": True,
    "skip_pycache": True,
    "skip_venv": True,
    "skip_images": True,
    "skip_binaries": True,
}
 
 
# ─────────────────────────────────────────────────────────────────────────────
# THEME MANAGER
# ─────────────────────────────────────────────────────────────────────────────
 
class ThemeManager:
    def __init__(self):
        self.current = "dark"
        self.colors = DARK_THEME.copy()
 
    def set_theme(self, name: str):
        self.current = name
        self.colors = DARK_THEME.copy() if name == "dark" else LIGHT_THEME.copy()
 
    def get(self, key: str) -> str:
        return self.colors.get(key, "#000000")
 
 
# ─────────────────────────────────────────────────────────────────────────────
# CONFIG MANAGER
# ─────────────────────────────────────────────────────────────────────────────
 
class ConfigManager:
    def __init__(self):
        self.data = DEFAULT_CONFIG.copy()
        self.load()
 
    def load(self):
        try:
            if os.path.exists(CONFIG_FILE):
                with open(CONFIG_FILE, "r", encoding="utf-8") as f:
                    saved = json.load(f)
                    self.data.update(saved)
        except Exception:
            pass
 
    def save(self):
        try:
            with open(CONFIG_FILE, "w", encoding="utf-8") as f:
                json.dump(self.data, f, indent=2)
        except Exception:
            pass
 
    def get(self, key, default=None):
        return self.data.get(key, default)
 
    def set(self, key, value):
        self.data[key] = value
        self.save()
 
 
# ─────────────────────────────────────────────────────────────────────────────
# LOGGER
# ─────────────────────────────────────────────────────────────────────────────
 
class Logger:
    def __init__(self):
        self.entries = []
 
    def log(self, msg: str, level: str = "INFO"):
        ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        entry = f"[{ts}] [{level}] {msg}"
        self.entries.append(entry)
 
    def log_error(self, msg: str):
        self.log(msg, "ERROR")
 
    def log_skip(self, path: str, reason: str):
        self.log(f"SKIPPED {path}: {reason}", "SKIP")
 
    def flush(self):
        try:
            with open(LOG_FILE, "a", encoding="utf-8") as f:
                f.write("\n".join(self.entries) + "\n")
            self.entries.clear()
        except Exception:
            pass
 
 
# ─────────────────────────────────────────────────────────────────────────────
# FILE COLLECTOR
# ─────────────────────────────────────────────────────────────────────────────
 
class FileCollector:
    def __init__(self, config: ConfigManager, logger: Logger):
        self.config = config
        self.logger = logger
 
    def _should_skip_dir(self, dirname: str) -> bool:
        name = dirname.lower()
        if self.config.get("skip_git") and name == ".git":
            return True
        if self.config.get("skip_node_modules") and name == "node_modules":
            return True
        if self.config.get("skip_pycache") and name == "__pycache__":
            return True
        if self.config.get("skip_venv") and name in {".venv", "venv", "env", ".env"}:
            return True
        return False
 
    def _should_skip_file(self, filepath: str) -> tuple[bool, str]:
        ext = Path(filepath).suffix.lower()
        if self.config.get("skip_images") and ext in IMAGE_EXTENSIONS:
            return True, "image file"
        if self.config.get("skip_binaries") and ext in BINARY_EXTENSIONS:
            return True, "binary file"
        return False, ""
 
    def collect(self, root: str, raw_paths: list[str]) -> list[str]:
        """Collect and expand all paths relative to root."""
        seen = set()
        result = []
 
        for raw in raw_paths:
            raw = raw.strip()
            if not raw or raw.startswith("#"):
                continue
 
            # Normalize path separators
            raw = raw.replace("\\", "/").strip("/")
            abs_path = os.path.join(root, raw)
 
            if os.path.isfile(abs_path):
                rel = os.path.relpath(abs_path, root).replace("\\", "/")
                skip, reason = self._should_skip_file(abs_path)
                if skip:
                    self.logger.log_skip(rel, reason)
                    continue
                if rel not in seen:
                    seen.add(rel)
                    result.append(rel)
 
            elif os.path.isdir(abs_path):
                for dirpath, dirnames, filenames in os.walk(abs_path):
                    # Filter directories in-place
                    dirnames[:] = [d for d in dirnames if not self._should_skip_dir(d)]
                    for fname in sorted(filenames):
                        fp = os.path.join(dirpath, fname)
                        rel = os.path.relpath(fp, root).replace("\\", "/")
                        skip, reason = self._should_skip_file(fp)
                        if skip:
                            self.logger.log_skip(rel, reason)
                            continue
                        if rel not in seen:
                            seen.add(rel)
                            result.append(rel)
            else:
                self.logger.log_error(f"Path not found: {abs_path}")
 
        result.sort()
        return result
 
 
# ─────────────────────────────────────────────────────────────────────────────
# STATISTICS MANAGER
# ─────────────────────────────────────────────────────────────────────────────
 
class StatisticsManager:
    def calculate(self, root: str, files: list[str]) -> dict:
        total_lines = 0
        total_chars = 0
        errors = []
 
        for rel in files:
            abs_path = os.path.join(root, rel)
            try:
                with open(abs_path, "r", encoding="utf-8", errors="replace") as f:
                    content = f.read()
                    total_chars += len(content)
                    total_lines += content.count("\n") + (1 if content and not content.endswith("\n") else 0)
            except Exception as e:
                errors.append((rel, str(e)))
 
        tokens = total_chars // 4
        return {
            "total_files": len(files),
            "total_lines": total_lines,
            "total_chars": total_chars,
            "estimated_tokens": tokens,
            "errors": errors,
        }
 
    @staticmethod
    def estimate_tokens(chars: int) -> int:
        return chars // 4
 
    @staticmethod
    def format_number(n: int) -> str:
        return f"{n:,}"
 
 
# ─────────────────────────────────────────────────────────────────────────────
# EXPORT MANAGER
# ─────────────────────────────────────────────────────────────────────────────
 
class ExportManager:
    def __init__(self, config: ConfigManager, logger: Logger):
        self.config = config
        self.logger = logger
 
    def _file_block(self, rel_path: str, content: str) -> str:
        sep = "#" * 80
        return (
            f"{sep}\n"
            f"FILE: {rel_path}\n"
            f"{sep}\n\n"
            f"{content}\n\n"
            f"{sep}\n"
            f"END FILE: {rel_path}\n"
            f"{sep}\n\n"
        )
 
    def _read_file(self, root: str, rel: str) -> tuple[str, str | None]:
        abs_path = os.path.join(root, rel)
        try:
            with open(abs_path, "r", encoding="utf-8", errors="replace") as f:
                return f.read(), None
        except PermissionError:
            return "", "Permission denied"
        except Exception as e:
            return "", str(e)
 
    def generate(
        self,
        root: str,
        files: list[str],
        output_dir: str,
        chunk_tokens: int,
        progress_cb=None,
        status_cb=None,
    ) -> dict:
        """Generate AI export package. Returns summary dict."""
        os.makedirs(output_dir, exist_ok=True)
 
        chunk_chars = chunk_tokens * 4
        parts = []
        current_part_files = []
        current_part_content = []
        current_part_chars = 0
        part_index = 1
        total_lines = 0
        total_chars_all = 0
        skipped = []
 
        total = len(files)
        for i, rel in enumerate(files):
            if status_cb:
                status_cb(f"Reading {i+1}/{total}: {rel}")
            if progress_cb:
                progress_cb((i + 1) / total * 0.7)
 
            content, err = self._read_file(root, rel)
            if err:
                self.logger.log_error(f"{rel}: {err}")
                skipped.append((rel, err))
                continue
 
            block = self._file_block(rel, content)
            block_chars = len(block)
            total_lines += content.count("\n")
            total_chars_all += len(content)
 
            # If this single file exceeds chunk size, it goes alone
            if current_part_chars + block_chars > chunk_chars and current_part_files:
                parts.append((part_index, current_part_files, current_part_content))
                part_index += 1
                current_part_files = []
                current_part_content = []
                current_part_chars = 0
 
            current_part_files.append(rel)
            current_part_content.append(block)
            current_part_chars += block_chars
 
        # Flush last part
        if current_part_files:
            parts.append((part_index, current_part_files, current_part_content))
 
        # Write parts
        for idx, (p_num, p_files, p_blocks) in enumerate(parts):
            fname = os.path.join(output_dir, f"combined_code_part_{p_num:03d}.txt")
            if status_cb:
                status_cb(f"Saving part {p_num} of {len(parts)}...")
            if progress_cb:
                progress_cb(0.7 + (idx + 1) / len(parts) * 0.2)
            try:
                with open(fname, "w", encoding="utf-8") as f:
                    f.writelines(p_blocks)
            except Exception as e:
                self.logger.log_error(f"Failed writing {fname}: {e}")
 
        summary = {
            "root": root,
            "date": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "total_files": len(files) - len(skipped),
            "total_lines": total_lines,
            "total_chars": total_chars_all,
            "estimated_tokens": total_chars_all // 4,
            "parts": len(parts),
            "skipped": skipped,
            "part_map": [(p, f) for p, f, _ in parts],
        }
 
        if status_cb:
            status_cb("Writing manifest...")
        self._write_manifest(output_dir, summary["part_map"])
 
        if status_cb:
            status_cb("Writing project summary...")
        self._write_project_summary(output_dir, summary)
 
        if status_cb:
            status_cb("Writing folder structure...")
        self._write_folder_structure(output_dir, files)
 
        if progress_cb:
            progress_cb(1.0)
        if status_cb:
            status_cb(f"Done. {summary['total_files']} files exported in {len(parts)} part(s).")
 
        self.logger.log(f"Export complete: {summary['total_files']} files, {len(parts)} parts")
        self.logger.flush()
 
        return summary
 
    def _write_manifest(self, output_dir: str, part_map: list):
        path = os.path.join(output_dir, "manifest.txt")
        lines = ["AI CODE EXPORT MANIFEST\n", "=" * 60 + "\n\n"]
        for part_num, files in part_map:
            lines.append(f"Part {part_num:03d}\n")
            lines.append("-" * 40 + "\n")
            for f in files:
                lines.append(f"  {f}\n")
            lines.append("\n")
        try:
            with open(path, "w", encoding="utf-8") as f:
                f.writelines(lines)
        except Exception as e:
            self.logger.log_error(f"manifest.txt: {e}")
 
    def _write_project_summary(self, output_dir: str, summary: dict):
        path = os.path.join(output_dir, "project_summary.txt")
        skipped_section = ""
        if summary["skipped"]:
            skipped_section = "\nSkipped Files:\n" + "\n".join(
                f"  {r}: {e}" for r, e in summary["skipped"]
            ) + "\n"
        content = (
            f"PROJECT EXPORT SUMMARY\n"
            f"{'=' * 60}\n\n"
            f"Project Root:\n  {summary['root']}\n\n"
            f"Export Date:\n  {summary['date']}\n\n"
            f"Files Exported:      {summary['total_files']:>10,}\n"
            f"Total Lines:         {summary['total_lines']:>10,}\n"
            f"Total Characters:    {summary['total_chars']:>10,}\n"
            f"Estimated Tokens:    {summary['estimated_tokens']:>10,}\n"
            f"Parts Generated:     {summary['parts']:>10,}\n"
            f"{skipped_section}"
        )
        try:
            with open(path, "w", encoding="utf-8") as f:
                f.write(content)
        except Exception as e:
            self.logger.log_error(f"project_summary.txt: {e}")
 
    def _write_folder_structure(self, output_dir: str, files: list[str]):
        path = os.path.join(output_dir, "folder_structure.txt")
        tree = {}
        for rel in files:
            parts = rel.replace("\\", "/").split("/")
            node = tree
            for p in parts:
                node = node.setdefault(p, {})
 
        lines = ["FOLDER STRUCTURE\n", "=" * 60 + "\n\n"]
 
        def walk(node, prefix="", indent=0):
            for i, (name, children) in enumerate(sorted(node.items())):
                is_last = i == len(node) - 1
                connector = "└── " if is_last else "├── "
                lines.append("    " * indent + connector + name + "\n")
                if children:
                    ext_prefix = "    " if is_last else "│   "
                    walk(children, prefix + ext_prefix, indent + 1)
 
        walk(tree)
        try:
            with open(path, "w", encoding="utf-8") as f:
                f.writelines(lines)
        except Exception as e:
            self.logger.log_error(f"folder_structure.txt: {e}")
 
    def get_preview(self, root: str, files: list[str], max_chars: int = 50000) -> str:
        """Get a preview of the export (first N chars)."""
        result = []
        chars = 0
        for rel in files:
            content, err = self._read_file(root, rel)
            if err:
                content = f"[ERROR: {err}]"
            block = self._file_block(rel, content)
            result.append(block)
            chars += len(block)
            if chars >= max_chars:
                result.append(f"\n... (preview truncated at {max_chars:,} chars) ...")
                break
        return "".join(result)
 
 
# ─────────────────────────────────────────────────────────────────────────────
# SEARCH MANAGER
# ─────────────────────────────────────────────────────────────────────────────
 
class SearchManager:
    @staticmethod
    def filter(files: list[str], query: str) -> list[str]:
        if not query:
            return files
        q = query.lower()
        return [f for f in files if q in f.lower()]
 
 
# ─────────────────────────────────────────────────────────────────────────────
# MAIN APPLICATION
# ─────────────────────────────────────────────────────────────────────────────
 
class CodeExporterApp:
    def __init__(self, root_win: tk.Tk):
        self.root_win = root_win
        self.root_win.title(APP_NAME)
        self.root_win.geometry("1400x900")
        self.root_win.minsize(1100, 700)
 
        # Core managers
        self.config = ConfigManager()
        self.theme = ThemeManager()
        self.logger = Logger()
        self.collector = FileCollector(self.config, self.logger)
        self.stats_mgr = StatisticsManager()
        self.export_mgr = ExportManager(self.config, self.logger)
        self.search_mgr = SearchManager()
 
        # State
        self.collected_files: list[str] = []
        self.filtered_files: list[str] = []
        self.last_export_summary: dict | None = None
        self.export_queue = queue.Queue()
        self._export_thread: threading.Thread | None = None
 
        # Apply saved theme
        self.theme.set_theme(self.config.get("theme", "dark"))
 
        # Build UI
        self._build_ui()
        self._apply_theme()
 
        # Restore saved root
        saved_root = self.config.get("last_root_directory", "")
        if saved_root:
            self.root_var.set(saved_root)
 
        # Restore saved preset
        saved_preset = self.config.get("ai_preset", "Generic")
        if saved_preset in AI_PRESETS:
            self.preset_var.set(saved_preset)
            self._on_preset_change()
 
        self.update_status("Ready. Select a project root and paste paths.")
        self.root_win.after(100, self._poll_queue)
 
    # ─── UI CONSTRUCTION ───────────────────────────────────────────────────
 
    def _build_ui(self):
        c = self.theme.colors
 
        # Configure ttk styles
        self.style = ttk.Style()
        self.style.theme_use("clam")
 
        # Main container
        self.main_frame = tk.Frame(self.root_win, bg=c["bg"])
        self.main_frame.pack(fill=tk.BOTH, expand=True)
 
        self._build_toolbar()
        self._build_options_bar()
        self._build_paned_area()
        self._build_output_area()
        self._build_status_bar()
 
    def _build_toolbar(self):
        c = self.theme.colors
        self.toolbar = tk.Frame(self.main_frame, bg=c["panel"], height=50, padx=8, pady=6)
        self.toolbar.pack(fill=tk.X, side=tk.TOP)
        self.toolbar.pack_propagate(False)
 
        # App title
        tk.Label(
            self.toolbar, text="⚡ " + APP_NAME,
            bg=c["panel"], fg=c["accent"],
            font=("Consolas", 13, "bold")
        ).pack(side=tk.LEFT, padx=(4, 16))
 
        separator = tk.Frame(self.toolbar, bg=c["border"], width=1)
        separator.pack(side=tk.LEFT, fill=tk.Y, padx=4)
 
        buttons = [
            ("🌓 Theme",         self.toggle_theme,        "accent"),
            ("📁 Root Folder",   self.select_root_directory,"button"),
            ("🔍 Preview Files", self.preview_files,        "button"),
            ("📦 Generate Package", self.run_export_thread,  "success"),
            ("📋 Copy Output",   self.copy_output,          "button"),
            ("💾 Save Output",   self.save_output,          "button"),
            ("🗑 Clear",         self.clear_all,            "button"),
            ("✕ Exit",          self.root_win.quit,         "error"),
        ]
        self.toolbar_buttons = {}
        for label, cmd, style_key in buttons:
            color = c.get(style_key, c["button"])
            btn = tk.Button(
                self.toolbar, text=label, command=cmd,
                bg=color, fg=c["fg"],
                relief=tk.FLAT, padx=10, pady=4,
                cursor="hand2", bd=0,
                font=("Segoe UI", 9),
                activebackground=c["btn_hover"],
                activeforeground=c["fg"],
            )
            btn.pack(side=tk.LEFT, padx=3)
            self.toolbar_buttons[label] = btn
 
    def _build_options_bar(self):
        c = self.theme.colors
        self.options_bar = tk.Frame(self.main_frame, bg=c["panel"], padx=10, pady=6)
        self.options_bar.pack(fill=tk.X, side=tk.TOP)
 
        # Root display
        tk.Label(self.options_bar, text="Root:", bg=c["panel"], fg=c["muted"],
                 font=("Segoe UI", 9)).pack(side=tk.LEFT)
        self.root_var = tk.StringVar()
        self.root_entry = tk.Entry(
            self.options_bar, textvariable=self.root_var,
            bg=c["textbox"], fg=c["fg"], insertbackground=c["fg"],
            relief=tk.FLAT, font=("Consolas", 9), width=50,
            bd=2,
        )
        self.root_entry.pack(side=tk.LEFT, padx=(4, 16))
 
        # AI Preset
        tk.Label(self.options_bar, text="Export for:", bg=c["panel"], fg=c["muted"],
                 font=("Segoe UI", 9)).pack(side=tk.LEFT)
        self.preset_var = tk.StringVar(value=self.config.get("ai_preset", "Generic"))
        preset_cb = ttk.Combobox(
            self.options_bar, textvariable=self.preset_var,
            values=list(AI_PRESETS.keys()), state="readonly", width=12,
        )
        preset_cb.pack(side=tk.LEFT, padx=(4, 16))
        preset_cb.bind("<<ComboboxSelected>>", lambda e: self._on_preset_change())
 
        # Token display
        self.token_limit_var = tk.StringVar()
        tk.Label(self.options_bar, textvariable=self.token_limit_var,
                 bg=c["panel"], fg=c["accent"], font=("Segoe UI", 9, "italic")).pack(side=tk.LEFT, padx=(0, 16))
 
        # Checkboxes
        self.skip_vars = {}
        checks = [
            ("skip_git",          ".git"),
            ("skip_node_modules", "node_modules"),
            ("skip_pycache",      "__pycache__"),
            ("skip_venv",         ".venv"),
            ("skip_images",       "Images"),
            ("skip_binaries",     "Binaries"),
        ]
        for key, label in checks:
            var = tk.BooleanVar(value=self.config.get(key, True))
            self.skip_vars[key] = var
            cb = tk.Checkbutton(
                self.options_bar, text=f"Skip {label}", variable=var,
                bg=c["panel"], fg=c["fg"],
                selectcolor=c["textbox"],
                activebackground=c["panel"], activeforeground=c["fg"],
                font=("Segoe UI", 9), command=self._on_skip_change,
            )
            cb.pack(side=tk.LEFT, padx=3)
 
        self._on_preset_change()
 
    def _build_paned_area(self):
        c = self.theme.colors
        self.paned = ttk.PanedWindow(self.main_frame, orient=tk.HORIZONTAL)
        self.paned.pack(fill=tk.BOTH, expand=True, padx=6, pady=(4, 0))
 
        # ── LEFT: Path input ─────────────────────────────────────────────
        left_frame = tk.Frame(self.paned, bg=c["panel"], padx=6, pady=6)
        self.paned.add(left_frame, weight=2)
 
        tk.Label(left_frame, text="📝 Relative Paths",
                 bg=c["panel"], fg=c["accent"],
                 font=("Segoe UI", 10, "bold")).pack(anchor=tk.W)
        tk.Label(left_frame, text="Paste files/folders, one per line:",
                 bg=c["panel"], fg=c["muted"],
                 font=("Segoe UI", 8)).pack(anchor=tk.W, pady=(0, 4))
 
        self.path_input = scrolledtext.ScrolledText(
            left_frame,
            bg=c["textbox"], fg=c["fg"], insertbackground=c["fg"],
            relief=tk.FLAT, font=("Consolas", 10),
            wrap=tk.NONE, undo=True,
        )
        self.path_input.pack(fill=tk.BOTH, expand=True)
        self.path_input.bind("<KeyRelease>", lambda e: None)
 
        tk.Button(
            left_frame, text="▶ Resolve Paths",
            command=self.preview_files,
            bg=c["accent"], fg="#FFFFFF",
            relief=tk.FLAT, padx=10, pady=5,
            cursor="hand2", font=("Segoe UI", 9, "bold"),
        ).pack(fill=tk.X, pady=(6, 0))
 
        # ── CENTER: File preview ─────────────────────────────────────────
        center_frame = tk.Frame(self.paned, bg=c["panel"], padx=6, pady=6)
        self.paned.add(center_frame, weight=3)
 
        tk.Label(center_frame, text="📂 Files To Be Included",
                 bg=c["panel"], fg=c["accent"],
                 font=("Segoe UI", 10, "bold")).pack(anchor=tk.W)
 
        search_frame = tk.Frame(center_frame, bg=c["panel"])
        search_frame.pack(fill=tk.X, pady=(2, 4))
        tk.Label(search_frame, text="🔎", bg=c["panel"], fg=c["muted"]).pack(side=tk.LEFT)
        self.search_var = tk.StringVar()
        search_entry = tk.Entry(
            search_frame, textvariable=self.search_var,
            bg=c["textbox"], fg=c["fg"], insertbackground=c["fg"],
            relief=tk.FLAT, font=("Consolas", 9),
        )
        search_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=4)
        self.search_var.trace_add("write", lambda *a: self._apply_search())
 
        self.file_count_var = tk.StringVar(value="0 files")
        tk.Label(search_frame, textvariable=self.file_count_var,
                 bg=c["panel"], fg=c["muted"], font=("Segoe UI", 8)).pack(side=tk.RIGHT)
 
        # Treeview
        tree_frame = tk.Frame(center_frame, bg=c["panel"])
        tree_frame.pack(fill=tk.BOTH, expand=True)
 
        self.style.configure(
            "Files.Treeview",
            background=c["textbox"], foreground=c["fg"],
            fieldbackground=c["textbox"],
            rowheight=22, font=("Consolas", 9),
        )
        self.style.configure("Files.Treeview.Heading",
                             background=c["panel"], foreground=c["accent"],
                             font=("Segoe UI", 9, "bold"))
        self.style.map("Files.Treeview",
                       background=[("selected", c["select"])],
                       foreground=[("selected", c["fg"])])
 
        columns = ("path", "ext", "status")
        self.file_tree = ttk.Treeview(
            tree_frame, columns=columns,
            show="headings", style="Files.Treeview",
        )
        self.file_tree.heading("path", text="Relative Path",
                               command=lambda: self._sort_tree("path"))
        self.file_tree.heading("ext", text="Ext",
                               command=lambda: self._sort_tree("ext"))
        self.file_tree.heading("status", text="Status")
        self.file_tree.column("path", width=320, stretch=True)
        self.file_tree.column("ext", width=60, stretch=False)
        self.file_tree.column("status", width=70, stretch=False)
 
        vsb = ttk.Scrollbar(tree_frame, orient=tk.VERTICAL, command=self.file_tree.yview)
        hsb = ttk.Scrollbar(tree_frame, orient=tk.HORIZONTAL, command=self.file_tree.xview)
        self.file_tree.configure(yscrollcommand=vsb.set, xscrollcommand=hsb.set)
        self.file_tree.grid(row=0, column=0, sticky="nsew")
        vsb.grid(row=0, column=1, sticky="ns")
        hsb.grid(row=1, column=0, sticky="ew")
        tree_frame.rowconfigure(0, weight=1)
        tree_frame.columnconfigure(0, weight=1)
 
        self.file_tree.bind("<Double-1>", self._open_file_location)
        self._sort_state = {"col": None, "rev": False}
 
        # ── RIGHT: Statistics ─────────────────────────────────────────────
        right_frame = tk.Frame(self.paned, bg=c["panel"], padx=8, pady=6)
        self.paned.add(right_frame, weight=1)
 
        tk.Label(right_frame, text="📊 Statistics",
                 bg=c["panel"], fg=c["accent"],
                 font=("Segoe UI", 10, "bold")).pack(anchor=tk.W, pady=(0, 8))
 
        self.stat_vars = {}
        stats = [
            ("project_root",      "Project Root"),
            ("total_files",       "Total Files"),
            ("total_lines",       "Total Lines"),
            ("total_chars",       "Total Chars"),
            ("estimated_tokens",  "Est. Tokens"),
            ("export_parts",      "Export Parts"),
            ("last_export",       "Last Export"),
        ]
        for key, label in stats:
            row = tk.Frame(right_frame, bg=c["panel"])
            row.pack(fill=tk.X, pady=2)
            tk.Label(row, text=label + ":", bg=c["panel"], fg=c["muted"],
                     font=("Segoe UI", 8), width=14, anchor=tk.W).pack(side=tk.LEFT)
            var = tk.StringVar(value="—")
            self.stat_vars[key] = var
            tk.Label(row, textvariable=var, bg=c["panel"], fg=c["fg"],
                     font=("Consolas", 9), anchor=tk.W, wraplength=150).pack(side=tk.LEFT, fill=tk.X)
 
        # Token gauge
        tk.Label(right_frame, text="Token Usage:", bg=c["panel"], fg=c["muted"],
                 font=("Segoe UI", 8)).pack(anchor=tk.W, pady=(12, 2))
        self.gauge_canvas = tk.Canvas(right_frame, height=16, bg=c["textbox"],
                                      highlightthickness=0)
        self.gauge_canvas.pack(fill=tk.X, pady=(0, 4))
        self.gauge_pct_var = tk.StringVar(value="")
        tk.Label(right_frame, textvariable=self.gauge_pct_var, bg=c["panel"],
                 fg=c["muted"], font=("Segoe UI", 8)).pack(anchor=tk.W)
 
        # Output dir button
        self.open_output_btn = tk.Button(
            right_frame, text="📂 Open Export Folder",
            command=self._open_export_folder,
            bg=c["button"], fg=c["fg"],
            relief=tk.FLAT, padx=8, pady=4,
            cursor="hand2", font=("Segoe UI", 8),
        )
        self.open_output_btn.pack(fill=tk.X, pady=(12, 0))
 
    def _build_output_area(self):
        c = self.theme.colors
        out_frame = tk.Frame(self.main_frame, bg=c["panel"], padx=6, pady=6)
        out_frame.pack(fill=tk.X, side=tk.BOTTOM)
 
        out_frame2 = tk.Frame(self.main_frame, bg=c["panel"], padx=6, pady=0)
        out_frame2.pack(fill=tk.BOTH, expand=False, side=tk.BOTTOM)
 
        header = tk.Frame(out_frame2, bg=c["panel"])
        header.pack(fill=tk.X)
        tk.Label(header, text="📄 Output Preview",
                 bg=c["panel"], fg=c["accent"],
                 font=("Segoe UI", 10, "bold")).pack(side=tk.LEFT)
        tk.Button(header, text="Copy All", command=self.copy_output,
                  bg=c["button"], fg=c["fg"], relief=tk.FLAT, padx=8, pady=2,
                  cursor="hand2", font=("Segoe UI", 8),
                  ).pack(side=tk.RIGHT)
 
        self.output_text = scrolledtext.ScrolledText(
            out_frame2, height=10,
            bg=c["textbox"], fg=c["fg"], insertbackground=c["fg"],
            relief=tk.FLAT, font=("Consolas", 9),
            state=tk.DISABLED, wrap=tk.NONE,
        )
        self.output_text.pack(fill=tk.BOTH, expand=False)
 
        # Right-click menu
        self.output_menu = tk.Menu(self.output_text, tearoff=0)
        self.output_menu.add_command(label="Copy All", command=self.copy_output)
        self.output_menu.add_command(label="Select All",
                                     command=lambda: self.output_text.tag_add(tk.SEL, "1.0", tk.END))
        self.output_text.bind("<Button-3>", lambda e: self.output_menu.tk_popup(e.x_root, e.y_root))
 
        # Progress bar
        self.progress_var = tk.DoubleVar(value=0)
        self.progress_bar = ttk.Progressbar(
            out_frame2, variable=self.progress_var,
            maximum=1.0, mode="determinate",
        )
        self.progress_bar.pack(fill=tk.X, pady=(4, 0))
 
    def _build_status_bar(self):
        c = self.theme.colors
        self.status_bar = tk.Frame(self.main_frame, bg=c["border"], height=26)
        self.status_bar.pack(fill=tk.X, side=tk.BOTTOM)
        self.status_bar.pack_propagate(False)
 
        self.status_var = tk.StringVar(value="Ready")
        tk.Label(self.status_bar, textvariable=self.status_var,
                 bg=c["border"], fg=c["fg"], font=("Segoe UI", 8),
                 anchor=tk.W, padx=8).pack(side=tk.LEFT, fill=tk.Y)
 
        self.time_var = tk.StringVar()
        tk.Label(self.status_bar, textvariable=self.time_var,
                 bg=c["border"], fg=c["muted"], font=("Segoe UI", 8),
                 anchor=tk.E, padx=8).pack(side=tk.RIGHT, fill=tk.Y)
        self._tick_clock()
 
    # ─── THEME ─────────────────────────────────────────────────────────────
 
    def _apply_theme(self):
        c = self.theme.colors
 
        # Root window
        self.root_win.configure(bg=c["bg"])
 
        def recolor(widget):
            try:
                wtype = widget.winfo_class()
                if wtype in ("Frame", "Label", "Canvas"):
                    widget.configure(bg=c["bg"] if widget == self.main_frame else
                                     c["panel"] if hasattr(widget, "_panel") else
                                     widget.cget("bg"))
            except Exception:
                pass
            for child in widget.winfo_children():
                recolor(child)
 
        # Update ttk styles
        self.style.configure("TCombobox",
                             fieldbackground=c["textbox"],
                             background=c["button"],
                             foreground=c["fg"],
                             selectbackground=c["select"],
                             selectforeground=c["fg"])
        self.style.configure("Files.Treeview",
                             background=c["textbox"], foreground=c["fg"],
                             fieldbackground=c["textbox"])
        self.style.configure("Files.Treeview.Heading",
                             background=c["panel"], foreground=c["accent"])
        self.style.map("Files.Treeview",
                       background=[("selected", c["select"])],
                       foreground=[("selected", c["fg"])])
        self.style.configure("TScrollbar",
                             background=c["button"], troughcolor=c["textbox"])
        self.style.configure("Horizontal.TProgressbar",
                             background=c["success"], troughcolor=c["textbox"])
        self.style.configure("Vertical.TProgressbar",
                             background=c["success"], troughcolor=c["textbox"])
 
    def toggle_theme(self):
        new_theme = "light" if self.theme.current == "dark" else "dark"
        self.theme.set_theme(new_theme)
        self.config.set("theme", new_theme)
        # Rebuild UI
        for widget in self.main_frame.winfo_children():
            widget.destroy()
        self._build_ui()
        self._apply_theme()
        # Restore state
        saved_root = self.config.get("last_root_directory", "")
        if saved_root:
            self.root_var.set(saved_root)
        saved_preset = self.config.get("ai_preset", "Generic")
        self.preset_var.set(saved_preset)
        self._on_preset_change()
        if self.collected_files:
            self._populate_tree(self.filtered_files)
            self._update_statistics_display()
        self.update_status("Theme switched to " + new_theme)
 
    # ─── ACTIONS ───────────────────────────────────────────────────────────
 
    def select_root_directory(self):
        initial = self.root_var.get() or os.path.expanduser("~")
        path = filedialog.askdirectory(title="Select Project Root", initialdir=initial)
        if path:
            self.root_var.set(path)
            self.config.set("last_root_directory", path)
            self.stat_vars["project_root"].set(Path(path).name)
            self.update_status(f"Root set: {path}")
 
    def preview_files(self):
        root = self.root_var.get().strip()
        if not root:
            messagebox.showwarning("No Root", "Please select a project root folder first.")
            return
        if not os.path.isdir(root):
            messagebox.showerror("Invalid Root", f"Directory not found:\n{root}")
            return
 
        raw_text = self.path_input.get("1.0", tk.END)
        raw_paths = [line.strip() for line in raw_text.splitlines() if line.strip()]
        if not raw_paths:
            messagebox.showinfo("Empty", "Please paste at least one relative path.")
            return
 
        # Update config skip flags
        self._sync_skip_config()
 
        self.update_status("Resolving paths...")
        self.progress_var.set(0)
 
        def _run():
            files = self.collector.collect(root, raw_paths)
            self.export_queue.put(("preview_done", files))
 
        threading.Thread(target=_run, daemon=True).start()
 
    def _preview_done(self, files: list[str]):
        self.collected_files = files
        self._apply_search()
        self.update_status(f"{len(files)} file(s) resolved.")
        self.progress_var.set(0)
        # Trigger stat calculation in background
        self._calc_stats_async()
 
    def _calc_stats_async(self):
        root = self.root_var.get().strip()
        files = list(self.collected_files)
        chunk_tokens = self._get_chunk_tokens()
 
        def _run():
            stats = self.stats_mgr.calculate(root, files)
            self.export_queue.put(("stats_done", stats, chunk_tokens))
 
        threading.Thread(target=_run, daemon=True).start()
 
    def _stats_done(self, stats: dict, chunk_tokens: int):
        self.last_stats = stats
        self._update_statistics_display(stats, chunk_tokens)
 
    def _update_statistics_display(self, stats: dict | None = None, chunk_tokens: int | None = None):
        if stats is None:
            stats = getattr(self, "last_stats", None)
        if stats is None:
            return
        if chunk_tokens is None:
            chunk_tokens = self._get_chunk_tokens()
 
        sv = self.stat_vars
        root_path = self.root_var.get()
        sv["project_root"].set(Path(root_path).name if root_path else "—")
        sv["total_files"].set(f"{stats['total_files']:,}")
        sv["total_lines"].set(f"{stats['total_lines']:,}")
        sv["total_chars"].set(f"{stats['total_chars']:,}")
        sv["estimated_tokens"].set(f"{stats['estimated_tokens']:,}")
 
        # Parts estimate
        if chunk_tokens > 0 and stats["estimated_tokens"] > 0:
            parts = math.ceil(stats["estimated_tokens"] / chunk_tokens)
            sv["export_parts"].set(str(parts))
        else:
            sv["export_parts"].set("—")
 
        # Gauge
        if chunk_tokens > 0 and stats["estimated_tokens"] > 0:
            pct = min(stats["estimated_tokens"] / chunk_tokens, 10.0)  # cap at 10x
            fill_pct = min(pct / 10.0, 1.0)
            self.gauge_canvas.update_idletasks()
            w = self.gauge_canvas.winfo_width() or 160
            c = self.theme.colors
            self.gauge_canvas.delete("all")
            fill_color = c["success"] if pct < 1 else c["warning"] if pct < 3 else c["error"]
            self.gauge_canvas.create_rectangle(0, 0, int(w * fill_pct), 16, fill=fill_color, outline="")
            chunks = math.ceil(stats["estimated_tokens"] / chunk_tokens)
            self.gauge_pct_var.set(f"{stats['estimated_tokens']:,} tokens → {chunks} chunk(s)")
 
    def run_export_thread(self):
        root = self.root_var.get().strip()
        if not root:
            messagebox.showwarning("No Root", "Please select a project root folder first.")
            return
        if not self.collected_files:
            messagebox.showwarning("No Files", "Please resolve paths first using 'Preview Files'.")
            return
 
        output_dir = os.path.join(root, "AI_EXPORT")
        chunk_tokens = self._get_chunk_tokens()
 
        # Confirm overwrite
        if os.path.exists(output_dir):
            if not messagebox.askyesno("Overwrite?",
                                        f"AI_EXPORT folder already exists at:\n{output_dir}\n\nOverwrite?"):
                return
 
        self._sync_skip_config()
        self.progress_var.set(0)
        self.update_status("Starting export...")
 
        # Disable generate button
        for label, btn in self.toolbar_buttons.items():
            if "Generate" in label:
                btn.configure(state=tk.DISABLED)
 
        def _run():
            try:
                summary = self.export_mgr.generate(
                    root=root,
                    files=self.collected_files,
                    output_dir=output_dir,
                    chunk_tokens=chunk_tokens,
                    progress_cb=lambda v: self.export_queue.put(("progress", v)),
                    status_cb=lambda s: self.export_queue.put(("status", s)),
                )
                self.export_queue.put(("export_done", summary, output_dir))
            except Exception as e:
                self.export_queue.put(("export_error", str(e)))
 
        self._export_thread = threading.Thread(target=_run, daemon=True)
        self._export_thread.start()
 
    def _export_done(self, summary: dict, output_dir: str):
        self.last_export_summary = summary
        ts = datetime.now().strftime("%H:%M:%S")
        self.stat_vars["last_export"].set(ts)
        self.stat_vars["export_parts"].set(str(summary["parts"]))
 
        # Re-enable button
        for label, btn in self.toolbar_buttons.items():
            if "Generate" in label:
                btn.configure(state=tk.NORMAL)
 
        self.update_status(
            f"✓ Export complete: {summary['total_files']} files, "
            f"{summary['parts']} part(s) → {output_dir}"
        )
        self.progress_var.set(1.0)
 
        # Load preview of part 1
        part1 = os.path.join(output_dir, "combined_code_part_001.txt")
        if os.path.exists(part1):
            try:
                with open(part1, "r", encoding="utf-8", errors="replace") as f:
                    preview = f.read(80000)
                self._set_output(preview)
            except Exception:
                pass
 
        messagebox.showinfo(
            "Export Complete",
            f"Successfully exported {summary['total_files']} file(s)!\n\n"
            f"Parts:  {summary['parts']}\n"
            f"Lines:  {summary['total_lines']:,}\n"
            f"Tokens: {summary['estimated_tokens']:,}\n\n"
            f"Saved to:\n{output_dir}"
        )
 
    def copy_output(self):
        content = self.output_text.get("1.0", tk.END)
        if content.strip():
            self.root_win.clipboard_clear()
            self.root_win.clipboard_append(content)
            self.update_status("Output copied to clipboard.")
        else:
            messagebox.showinfo("Empty", "No output to copy.")
 
    def save_output(self):
        content = self.output_text.get("1.0", tk.END)
        if not content.strip():
            messagebox.showinfo("Empty", "No output to save.")
            return
        path = filedialog.asksaveasfilename(
            defaultextension=".txt",
            filetypes=[("Text files", "*.txt"), ("All files", "*.*")],
            initialfile=f"ai_export_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt",
        )
        if path:
            try:
                with open(path, "w", encoding="utf-8") as f:
                    f.write(content)
                self.update_status(f"Output saved: {path}")
            except Exception as e:
                messagebox.showerror("Save Error", str(e))
 
    def clear_all(self):
        self.path_input.delete("1.0", tk.END)
        self.collected_files.clear()
        self.filtered_files.clear()
        for item in self.file_tree.get_children():
            self.file_tree.delete(item)
        self._set_output("")
        self.progress_var.set(0)
        self.file_count_var.set("0 files")
        for key in self.stat_vars:
            self.stat_vars[key].set("—")
        self.gauge_canvas.delete("all")
        self.gauge_pct_var.set("")
        self.update_status("Cleared.")
 
    # ─── TREE / SEARCH ─────────────────────────────────────────────────────
 
    def _populate_tree(self, files: list[str]):
        for item in self.file_tree.get_children():
            self.file_tree.delete(item)
        for rel in files:
            ext = Path(rel).suffix.lower() or "(none)"
            self.file_tree.insert("", tk.END, values=(rel, ext, "✓"))
        self.file_count_var.set(f"{len(files)} file(s)")
 
    def _apply_search(self):
        query = self.search_var.get().strip() if hasattr(self, "search_var") else ""
        self.filtered_files = self.search_mgr.filter(self.collected_files, query)
        self._populate_tree(self.filtered_files)
 
    def _sort_tree(self, col: str):
        rev = self.file_tree.heading(col, option="text").startswith("▲")
        data = [(self.file_tree.set(k, col), k) for k in self.file_tree.get_children("")]
        data.sort(reverse=rev)
        for i, (_, k) in enumerate(data):
            self.file_tree.move(k, "", i)
        arrow = "▼" if rev else "▲"
        for c in ("path", "ext", "status"):
            self.file_tree.heading(c, text={"path": "Relative Path", "ext": "Ext", "status": "Status"}[c] +
                                   (" " + arrow if c == col else ""))
 
    def _open_file_location(self, event):
        sel = self.file_tree.selection()
        if not sel:
            return
        rel = self.file_tree.item(sel[0])["values"][0]
        root = self.root_var.get().strip()
        abs_path = os.path.join(root, rel)
        folder = os.path.dirname(abs_path)
        try:
            import subprocess, platform
            if platform.system() == "Windows":
                subprocess.Popen(f'explorer /select,"{abs_path}"')
            elif platform.system() == "Darwin":
                subprocess.Popen(["open", "-R", abs_path])
            else:
                subprocess.Popen(["xdg-open", folder])
        except Exception:
            pass
 
    def _open_export_folder(self):
        root = self.root_var.get().strip()
        if not root:
            return
        folder = os.path.join(root, "AI_EXPORT")
        if not os.path.exists(folder):
            messagebox.showinfo("Not Found", "AI_EXPORT folder does not exist yet.")
            return
        try:
            import subprocess, platform
            if platform.system() == "Windows":
                subprocess.Popen(["explorer", folder])
            elif platform.system() == "Darwin":
                subprocess.Popen(["open", folder])
            else:
                subprocess.Popen(["xdg-open", folder])
        except Exception:
            pass
 
    # ─── HELPERS ───────────────────────────────────────────────────────────
 
    def _on_preset_change(self):
        preset = self.preset_var.get()
        self.config.set("ai_preset", preset)
        info = AI_PRESETS.get(preset, AI_PRESETS["Generic"])
        self.token_limit_var.set(f"Chunk: {info['tokens']:,} tokens")
 
    def _on_skip_change(self):
        self._sync_skip_config()
 
    def _sync_skip_config(self):
        for key, var in self.skip_vars.items():
            val = var.get()
            self.config.data[key] = val
            self.collector.config.data[key] = val
        self.config.save()
 
    def _get_chunk_tokens(self) -> int:
        preset = self.preset_var.get()
        return AI_PRESETS.get(preset, AI_PRESETS["Generic"])["tokens"]
 
    def _set_output(self, text: str):
        self.output_text.configure(state=tk.NORMAL)
        self.output_text.delete("1.0", tk.END)
        self.output_text.insert("1.0", text)
        self.output_text.configure(state=tk.DISABLED)
 
    def update_status(self, msg: str):
        self.status_var.set(msg)
 
    def _tick_clock(self):
        self.time_var.set(datetime.now().strftime("%Y-%m-%d  %H:%M:%S"))
        self.root_win.after(1000, self._tick_clock)
 
    # ─── QUEUE POLLING ─────────────────────────────────────────────────────
 
    def _poll_queue(self):
        try:
            while True:
                item = self.export_queue.get_nowait()
                kind = item[0]
 
                if kind == "preview_done":
                    self._preview_done(item[1])
 
                elif kind == "stats_done":
                    self._stats_done(item[1], item[2])
 
                elif kind == "progress":
                    self.progress_var.set(item[1])
 
                elif kind == "status":
                    self.update_status(item[1])
 
                elif kind == "export_done":
                    self._export_done(item[1], item[2])
 
                elif kind == "export_error":
                    messagebox.showerror("Export Error", item[1])
                    self.update_status("Export failed.")
                    for label, btn in self.toolbar_buttons.items():
                        if "Generate" in label:
                            btn.configure(state=tk.NORMAL)
 
        except queue.Empty:
            pass
        finally:
            self.root_win.after(50, self._poll_queue)
 
 
# ─────────────────────────────────────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────────────────────────────────────
 
def main():
    root = tk.Tk()
    root.withdraw()  # Hide until fully built
    app = CodeExporterApp(root)
    root.deiconify()
    root.mainloop()
 
 
if __name__ == "__main__":
    main()
 