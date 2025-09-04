import os
import shutil

def sincronizar_overlay(template, overlay):
    for root, dirs, files in os.walk(template):
        rel_path = os.path.relpath(root, template)
        overlay_path = os.path.join(overlay, rel_path)

        if "scripts-init" in rel_path.split(os.sep):
            continue

        if not os.path.exists(overlay_path):
            os.makedirs(overlay_path)
            print(f"Creada carpeta: {overlay_path}")

        for file in files:
            template_file = os.path.join(root, file)
            overlay_file = os.path.join(overlay_path, file)

            if not os.path.exists(overlay_file):
                shutil.copy2(template_file, overlay_file)

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    template = os.path.abspath(os.path.join(script_dir, "../../template"))
    overlay = os.path.abspath(os.path.join(script_dir, ".."))

    if not os.path.exists(template):
        print(f"La carpeta de origen '{template}' no existe.")
    elif not os.path.exists(overlay):
        os.makedirs(overlay)
        print(f"Creada carpeta de destino: {overlay}")

    sincronizar_overlay(template, overlay)