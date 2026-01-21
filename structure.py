import os
import tkinter as tk
from tkinter import filedialog, ttk, messagebox
import platform

# Configurable themes
THEMES = {
    "Sunny": {
        "bg": "#FFF8DC", "fg": "#000000",
        "tree_bg": "#FFF8E7", "highlight": "#FFA500"
    },
    "Blue Moon": {
        "bg": "#1C1C2E", "fg": "#E0E0E0",
        "tree_bg": "#2B2B3C", "highlight": "#3399FF"
    }
}

EXCLUDED_DIRS = {'node_modules', '.git', '.venv', '__pycache__', '.mypy_cache', '.idea', '.vscode'}
EXCLUDED_EXTS = {'.png', '.jpg', '.jpeg', '.gif', '.exe', '.dll', '.pdf', '.zip', '.mp4', '.mp3'}
HEURISTICS = {
    'main.py': '→ main application logic',
    'index.js': '→ entry point',
    'App.js': '→ React root component',
    'model.py': '→ ML model definition',
    'routes.py': '→ Flask routes',
}

class FileStructureApp:
    def __init__(self, root):
        self.root = root
        self.root.title("🧠 Smart Project Structure Explorer")
        self.root.geometry("1000x700")
        self.theme_name = "Sunny"
        self.apply_theme()

        self.tree_frame = ttk.Frame(self.root)
        self.tree_frame.pack(fill=tk.BOTH, expand=True)

        self.setup_ui()
        self.path_map = {}
        self.root_dir = ""
        self.search_result_frame = None
        self.search_result_listbox = None

    def setup_ui(self):
        top = ttk.Frame(self.root)
        top.pack(fill=tk.X)

        ttk.Button(top, text="☀️/🌙 ", command=self.toggle_theme).pack(side=tk.LEFT, padx=5, pady=5)
        ttk.Button(top, text="📁 Select Folder", command=self.select_folder).pack(side=tk.LEFT, padx=5, pady=5)
        ttk.Button(top, text="📋 Copy Structure", command=self.copy_structure).pack(side=tk.LEFT, padx=5)
        ttk.Button(top, text="🔍 Search", command=self.activate_search).pack(side=tk.LEFT, padx=5)
        ttk.Button(top, text="❌ Exit", command=self.root.quit).pack(side=tk.RIGHT, padx=5)

        # 🌟 NEW FEATURE — Depth Limit Controls
        self.limit_depth_var = tk.BooleanVar(value=False)
        self.max_depth_var = tk.StringVar(value="2")  # Default depth

        self.depth_checkbox = tk.Checkbutton(
            top, text="Limit Depth", variable=self.limit_depth_var,
            bg=THEMES[self.theme_name]["bg"], fg=THEMES[self.theme_name]["fg"],
            font=("Segoe UI", 10, "bold"), command=self.toggle_depth_entry
        )
        self.depth_checkbox.pack(side=tk.LEFT, padx=10)

        self.depth_entry = ttk.Entry(top, textvariable=self.max_depth_var, width=5, state="disabled")
        self.depth_entry.pack(side=tk.LEFT, padx=(0, 10))

        # --- Existing Search Bar & Buttons (Untouched except reposition) ---
        self.search_frame = tk.Frame(top, bg=THEMES[self.theme_name]["bg"])
        self.search_var = tk.StringVar()
        self.search_bar = ttk.Entry(self.search_frame, textvariable=self.search_var, font=("Segoe UI", 11))
        self.search_bar.config(width=50)
        self.search_bar.bind("<KeyRelease>", self.perform_search)
        self.search_bar.pack(side=tk.LEFT, padx=(0, 10), pady=5)

        self.copy_names_btn = tk.Button(
            self.search_frame, text="📄 Copy Filenames",
            command=self.copy_search_filenames,
            bg=THEMES[self.theme_name]["highlight"], fg="white",
            relief="flat", font=("Segoe UI", 10, "bold"),
            bd=0, padx=10, pady=3
        )
        self.copy_names_btn.pack(side=tk.LEFT, padx=5)

        self.copy_paths_btn = tk.Button(
            self.search_frame, text="📁 Copy + Paths",
            command=self.copy_search_filepaths,
            bg=THEMES[self.theme_name]["highlight"], fg="white",
            relief="flat", font=("Segoe UI", 10, "bold"),
            bd=0, padx=10, pady=3
        )
        self.copy_paths_btn.pack(side=tk.LEFT, padx=5)

        self.search_frame.pack_forget()

        # Inline search result frame attached to search bar (Untouched)
        self.inline_result_frame = tk.Frame(self.root, bg=THEMES[self.theme_name]["tree_bg"], bd=1, relief="raised")
        self.inline_result_frame.place_forget()
        self.inline_result_listbox = tk.Listbox(
            self.inline_result_frame,
            font=("Segoe UI", 10),
            height=5,
            activestyle="dotbox",
            selectbackground=THEMES[self.theme_name]["highlight"],
            bg=THEMES[self.theme_name]["tree_bg"],
            fg=THEMES[self.theme_name]["fg"]
        )
        self.inline_result_listbox.pack(fill=tk.BOTH, expand=True)
        self.inline_result_listbox.bind("<Double-Button-1>", self.on_search_result_select)
        self.inline_result_listbox.bind("<Return>", self.on_search_result_select)

        # Treeview (Untouched)
        self.tree = ttk.Treeview(self.tree_frame)
        self.tree.pack(fill=tk.BOTH, expand=True, side=tk.LEFT)
        self.tree.bind("<Double-1>", self.open_path_popup)

        scrollbar = ttk.Scrollbar(self.tree_frame, orient="vertical", command=self.tree.yview)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        self.tree.configure(yscrollcommand=scrollbar.set)

    # 🌟 NEW METHOD for toggling entry box
    def toggle_depth_entry(self):
        if self.limit_depth_var.get():
            self.depth_entry.config(state="normal")
        else:
            self.depth_entry.config(state="disabled")

    # --- All below methods are UNTOUCHED except where noted ---
    def apply_theme(self):
        t = THEMES[self.theme_name]
        self.root.configure(bg=t["bg"])
        style = ttk.Style()
        style.theme_use('clam')
        style.configure("Treeview", background=t["tree_bg"], fieldbackground=t["tree_bg"], foreground=t["fg"])
        style.configure("TButton", background=t["bg"], foreground=t["fg"], padding=6, relief="flat", borderwidth=0)
        style.map("TButton", background=[("active", t["highlight"])], foreground=[("active", "#FFFFFF")])
        style.configure("TEntry", fieldbackground=t["tree_bg"], foreground=t["fg"])

    def toggle_theme(self):
        self.theme_name = "Blue Moon" if self.theme_name == "Sunny" else "Sunny"
        self.apply_theme()

    # --- Modified select_folder to pass optional depth limit ---
    def select_folder(self):
        folder = filedialog.askdirectory()
        if not folder:
            return
        self.root_dir = folder
        self.tree.delete(*self.tree.get_children())
        self.path_map.clear()

        depth_limit = None
        if self.limit_depth_var.get():
            try:
                depth_limit = int(self.max_depth_var.get())
            except ValueError:
                messagebox.showerror("Invalid Input", "Please enter a valid number for depth limit.")
                return

        self.build_tree(folder, "", 0, depth_limit)
        self.expand_all()

    # --- Modified build_tree to include depth tracking ---
    def build_tree(self, current_path, parent, current_depth=0, max_depth=None):
        if max_depth is not None and current_depth > max_depth:
            return
        name = os.path.basename(current_path)
        if os.path.isdir(current_path):
            if name in EXCLUDED_DIRS:
                node = self.tree.insert(parent, 'end', text=f"📁 {name}/  → (skipped: irrelevant)", open=True)
                self.path_map[node] = current_path
                return
            node = self.tree.insert(parent, 'end', text=f"📁 {name}/", open=True)
            self.path_map[node] = current_path
            try:
                for item in sorted(os.listdir(current_path)):
                    self.build_tree(os.path.join(current_path, item), node, current_depth + 1, max_depth)
            except Exception:
                pass
        else:
            ext = os.path.splitext(name)[1]
            if ext in EXCLUDED_EXTS:
                return
            label = f"📄 {name}"
            if name in HEURISTICS:
                label += f"  ({HEURISTICS[name]})"
            node = self.tree.insert(parent, 'end', text=label)
            self.path_map[node] = current_path

    # Remaining methods are UNTOUCHED except copy_structure & generate_text
    def expand_all(self):
        def recurse(nodes):
            for node in nodes:
                self.tree.item(node, open=True)
                recurse(self.tree.get_children(node))
        recurse(self.tree.get_children())

    # --- MODIFIED copy_structure and generate_text ---
    def copy_structure(self):
        lines = []
        # generate_text now respects folder open/closed state
        self.generate_text(self.tree.get_children(), 0, lines)
        structure_text = "\n".join(lines)
        self.clipboard_copy(structure_text)
        messagebox.showinfo("Success", "📋 Project structure copied!")

    def generate_text(self, nodes, level, lines):
        """Recursively generate structure lines.
        - If folder is collapsed → copy only its name.
        - If open → copy its contents recursively.
        """
        prefix = "    " * level
        for node in nodes:
            text = self.tree.item(node, "text")
            lines.append(f"{prefix}{text}")

            # --- NEW LOGIC: Skip children if collapsed ---
            is_open = self.tree.item(node, "open")
            children = self.tree.get_children(node)

            if children and not is_open:
                # Folder closed → don't expand children
                continue
            elif children:
                # Folder open → continue recursion
                self.generate_text(children, level + 1, lines)
            # Files have no children → automatically skipped from recursion

    # --- UNTOUCHED BELOW ---
    def activate_search(self):
        self.search_var.set("")
        self.inline_result_listbox.delete(0, tk.END)
        self.inline_result_frame.place_forget()
        self.search_frame.pack(side=tk.LEFT, padx=4)

    def perform_search(self, event=None):
        query = self.search_var.get().lower()
        results = []

        def recurse(node):
            label = self.tree.item(node, "text").lower()
            if query in label:
                results.append((node, self.tree.item(node, "text")))
            for child in self.tree.get_children(node):
                recurse(child)

        for node in self.tree.get_children():
            recurse(node)

        self.inline_result_listbox.delete(0, tk.END)
        self.search_matches = results
        if results:
            for _, label in results:
                self.inline_result_listbox.insert(tk.END, label)
        else:
            self.inline_result_listbox.insert(tk.END, "❌ No results found.")

        self.root.update_idletasks()
        x = self.search_bar.winfo_rootx() - self.root.winfo_rootx()
        y = self.search_bar.winfo_rooty() - self.root.winfo_rooty() - self.inline_result_listbox.winfo_reqheight()
        w = self.search_bar.winfo_width()
        self.inline_result_frame.place(x=x, y=y, width=w)

    def on_search_result_select(self, event):
        widget = event.widget
        if not widget:
            return
        index = widget.curselection()
        if not index:
            return
        selected_label = widget.get(index)
        path = None
        for nid, lbl in self.search_matches:
            if lbl == selected_label:
                path = self.path_map[nid]
                break
        if path:
            self.inline_result_frame.place_forget()
            self.show_copy_options_popup(path)

    def show_copy_options_popup(self, path):
        popup = tk.Toplevel(self.root)
        popup.title("📋 Copy Path")
        popup.geometry("500x100")

        abs_path = os.path.abspath(path)
        rel_path = os.path.relpath(path, self.root_dir)

        def copy_abs():
            self.clipboard_copy(abs_path)
            popup.destroy()

        def copy_rel():
            self.clipboard_copy(rel_path)
            popup.destroy()

        tk.Label(popup, text=abs_path, wraplength=400).pack(pady=5)
        tk.Button(popup, text="📋 Copy Full Path", command=copy_abs).pack(side=tk.LEFT, padx=10)
        tk.Button(popup, text="📋 Copy Relative Path", command=copy_rel).pack(side=tk.RIGHT, padx=10)

    def open_path_popup(self, event):
        item = self.tree.identify_row(event.y)
        if item:
            path = self.path_map.get(item)
            if path:
                self.show_copy_options_popup(path)

    def copy_search_filenames(self):
        filenames = [label.split('📄 ')[-1].strip() for _, label in self.search_matches]
        text = "\n".join(filenames)
        self.clipboard_copy(text)
        messagebox.showinfo("Copied", f"📄 {len(filenames)} filenames copied to clipboard.")

    def copy_search_filepaths(self):
        filepaths = [os.path.abspath(self.path_map[nid]) for nid, _ in self.search_matches]
        text = "\n".join(filepaths)
        self.clipboard_copy(text)
        messagebox.showinfo("Copied", f"📁 {len(filepaths)} full paths copied to clipboard.")

    def clipboard_copy(self, text):
        self.root.clipboard_clear()
        self.root.clipboard_append(text)
        self.root.update()

if __name__ == "__main__":
    root = tk.Tk()
    app = FileStructureApp(root)
    root.mainloop()