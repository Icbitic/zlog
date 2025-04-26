import os

def list_swift_files_recursive(directory):
    for root, _, files in os.walk(directory):
        for filename in files:
            if filename.endswith('.swift'):
                filepath = os.path.join(root, filename)
                print(f"1. filename: {os.path.relpath(filepath, directory)}\n")
                with open(filepath, 'r', encoding='utf-8') as file:
                    print(file.read())
                print("\n" + "-"*40 + "\n")  # Separator between files

if __name__ == "__main__":
    # Change this to your target directory
    target_directory = '.'
    list_swift_files_recursive(target_directory)

