#!/usr/bin/env python3


def replace_in_file(file_path: str, old_string: str, new_string: str) -> None:
    """Replaces all occurrences of old_string with new_string in the specified file."""
    import os

    try:
        # 1. Read the file
        with open(file_path, "r", encoding="utf-8") as file:
            data = file.read()

        # 2. Replace the target string
        data = data.replace(old_string, new_string)

        # 3. Write the changes back
        with open(file_path, "w", encoding="utf-8") as file:
            file.write(data)

        print("Replacement complete.")
    except FileNotFoundError:
        print("The file was not found.")
    except Exception as e:
        print(f"An error occurred: {e}")


def fix_include_folder(project_name: str) -> None:
    """
    renames the ./include/ctemplate folder to ./include/<project_name>
    fixes the guard name in ./include/<project_name>/fns.h from __CTEMPLATE_FNS_H__ to __<PROJECT_NAME>_FNS_H__
    """
    import os

    # Define the current and new directory names
    old_name = "./include/ctemplate"
    new_name = f"./include/{project_name}"

    try:
        os.rename(old_name, new_name)
        print(f"Directory renamed from {old_name} to {new_name}")
    except FileNotFoundError:
        print("The source directory does not exist.")
    except FileExistsError:
        print("A directory with the new name already exists.")
    except OSError as e:
        print(f"Error: {e}")
    replace_in_file(
        "./include/{}/fns.h".format(project_name),
        "ctemplate".upper(),
        project_name.upper(),
    )


def main():
    project_name = input("Enter the C project name: ")
    print(f"Creating C project: {project_name}")
    fix_include_folder(project_name)
    replace_in_file("./Makefile", "ctemplate", project_name)
    replace_in_file("./src/main.c", "ctemplate", project_name)
    replace_in_file("./src/fns.c", "ctemplate", project_name)
    replace_in_file("./tests/src/test_fns.c", "ctemplate", project_name)


if __name__ == "__main__":
    main()
