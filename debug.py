# debug.pyimport re
from pathlib import Path
from tkinter import Tk, filedialog

# --------------------------------------------------
# EXACT AUDIT FOR SESSION VS ATTENDANCESESSION
# --------------------------------------------------

SEARCHES = {
    "imports": [
        r"from\s+.*session.*import\s+Session",
        r"import\s+Session",
    ],
    "queries": [
        r"db\.query\s*\(\s*Session\s*\)",
        r"query\s*\(\s*Session\s*\)",
    ],
    "relationships": [
        r'relationship\("Session"\)',
        r"relationship\s*\(\s*Session\s*\)",
    ],
    "foreign_keys": [
        r'ForeignKey\("sessions\.id"\)',
        r"sessions\.id",
    ],
    "attendance": [
        r"\bAttendanceSession\b",
        r"attendance_sessions",
    ],
}


def scan_file(filepath):
    results = []

    try:
        text = filepath.read_text(
            encoding="utf-8",
            errors="ignore"
        )

        for category, patterns in SEARCHES.items():

            for pattern in patterns:

                matches = list(
                    re.finditer(
                        pattern,
                        text,
                        re.IGNORECASE
                    )
                )

                for m in matches:

                    line_number = (
                        text[:m.start()].count("\n") + 1
                    )

                    results.append({
                        "file": str(filepath),
                        "line": line_number,
                        "category": category,
                        "match": m.group(0)
                    })

    except:
        pass

    return results


def main():

    root = Tk()
    root.withdraw()

    folder = filedialog.askdirectory(
        title="Select Project Folder"
    )

    if not folder:
        return

    project = Path(folder)

    files = [
        p for p in project.rglob("*")
        if p.is_file()
        and p.suffix in {
            ".py",
            ".js",
            ".ts",
            ".tsx",
            ".sql",
            ".java",
            ".yaml",
            ".yml",
            ".json"
        }
    ]

    findings = []

    for file in files:
        findings.extend(
            scan_file(file)
        )

    report = []

    report.append("=" * 60)
    report.append("SESSION MODEL AUDIT REPORT")
    report.append("=" * 60)
    report.append("")

    counts = {
        k: 0
        for k in SEARCHES
    }

    for item in findings:

        file_name = Path(
            item["file"]
        ).name

        # Ignore session.py itself

        if file_name == "session.py":
            continue

        counts[item["category"]] += 1

    report.append("Search Summary")
    report.append("-" * 60)

    report.append(
        f"Session Imports       : {counts['imports']}"
    )

    report.append(
        f"Session Queries       : {counts['queries']}"
    )

    report.append(
        f"Session Relationships : {counts['relationships']}"
    )

    report.append(
        f"Session Foreign Keys  : {counts['foreign_keys']}"
    )

    report.append(
        f"Attendance References : {counts['attendance']}"
    )

    report.append("")
    report.append("=" * 60)
    report.append("DETAILED REFERENCES")
    report.append("=" * 60)
    report.append("")

    for item in findings:

        file_name = Path(
            item["file"]
        ).name

        if file_name == "session.py":
            continue

        report.append(
            f"[{item['category'].upper()}] "
            f"{item['file']}:{item['line']} "
            f"-> {item['match']}"
        )

    report.append("")
    report.append("=" * 60)
    report.append("ANALYSIS")
    report.append("=" * 60)
    report.append("")

    total_session_usage = (
        counts["imports"]
        + counts["queries"]
        + counts["relationships"]
        + counts["foreign_keys"]
    )

    if total_session_usage == 0:

        report.append(
            "RESULT: Session model appears UNUSED."
        )
        report.append(
            "VERDICT: Safe candidate for deletion."
        )
        report.append(
            "CONFIDENCE: HIGH"
        )

        report.append("")
        report.append(
            "Recommended:"
        )

        report.append(
            "1. Delete session.py"
        )

        report.append(
            "2. Remove Session import from models/__init__.py"
        )

        report.append(
            "3. Delete generated migration"
        )

        report.append(
            "4. Regenerate migration"
        )

        report.append(
            "5. Review migration"
        )

        report.append(
            "6. alembic upgrade head"
        )

    else:

        report.append(
            "RESULT: Session model is still referenced."
        )

        report.append(
            "VERDICT: DO NOT DELETE YET."
        )

        report.append(
            "Investigate detailed references above."
        )

    final_report = "\n".join(report)

    print("\n")
    print(final_report)

    output_file = (
        project /
        "SESSION_AUDIT_REPORT.txt"
    )

    output_file.write_text(
        final_report,
        encoding="utf-8"
    )

    print("\n")
    print(
        f"Report saved to:\n{output_file}"
    )


if __name__ == "__main__":
    main()