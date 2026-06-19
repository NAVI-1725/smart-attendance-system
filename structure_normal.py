import os
import tkinter as tk
from tkinter import filedialog, scrolledtext, messagebox


def get_tree(folder, prefix=""):
    result = []

    try:
        items = sorted(os.listdir(folder))
    except PermissionError:
        return [prefix + "[ACCESS DENIED]"]

    for i, item in enumerate(items):
        path = os.path.join(folder, item)
        is_last = i == len(items) - 1

        connector = "└── " if is_last else "├── "
        result.append(prefix + connector + item)

        if os.path.isdir(path):
            extension = "    " if is_last else "│   "
            result.extend(get_tree(path, prefix + extension))

    return result


def browse_folder():
    folder = filedialog.askdirectory()
    if not folder:
        return

    path_var.set(folder)

    tree = [os.path.basename(folder)]
    tree.extend(get_tree(folder))

    output.delete("1.0", tk.END)
    output.insert(tk.END, "\n".join(tree))


def save_output():
    content = output.get("1.0", tk.END).strip()

    if not content:
        messagebox.showwarning("Warning", "No folder structure generated.")
        return

    file_path = filedialog.asksaveasfilename(
        defaultextension=".txt",
        filetypes=[("Text Files", "*.txt")]
    )

    if file_path:
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content)

        messagebox.showinfo("Success", "Saved successfully!")


root = tk.Tk()
root.title("Folder Structure Viewer")
root.geometry("900x600")

path_var = tk.StringVar()

top_frame = tk.Frame(root)
top_frame.pack(fill="x", padx=10, pady=10)

tk.Entry(top_frame, textvariable=path_var).pack(
    side="left", fill="x", expand=True
)

tk.Button(
    top_frame,
    text="Browse",
    command=browse_folder
).pack(side="left", padx=5)

tk.Button(
    top_frame,
    text="Save TXT",
    command=save_output
).pack(side="left")

output = scrolledtext.ScrolledText(root, wrap=tk.WORD)
output.pack(fill="both", expand=True, padx=10, pady=10)

root.mainloop()