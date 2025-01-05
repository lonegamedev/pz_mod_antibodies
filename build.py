import os
import argparse
import shutil
from jinja2 import Environment, FileSystemLoader
import image_gen
import codecs

build_41_encoding_map = {
    "Translate/PL": "windows-1250",  # Polish
    "Translate/ES": "windows-1252",  # Spanish
    "Translate/DE": "windows-1252",  # German
    "Translate/FR": "windows-1252",  # French
    "Translate/FI": "windows-1252",  # Finnish
    "Translate/RU": "windows-1251",  # Russian
    "Translate/JA": "utf-8",         # Japanese
    "Translate/KO": "utf-8",         # Korean
    "Translate/ZH": "utf-8",         # Chinese
    "Translate/TH": "utf-8",         # Thai
    "Translate/TR": "windows-1254",  # Turkish
    "Translate/UK": "windows-1251",  # Ukrainian
    "Translate/PT": "windows-1252",  # Portuguese
    "Translate/IT": "windows-1252",  # Italian
    "Translate/NL": "windows-1252",  # Dutch
    "Translate/SV": "windows-1252",  # Swedish
    "Translate/NO": "windows-1252",  # Norwegian
    "Translate/DA": "windows-1252",  # Danish
    "Translate/CS": "windows-1250",  # Czech
    "Translate/HU": "windows-1250",  # Hungarian
    "Translate/RO": "windows-1250",  # Romanian
    "Translate/HR": "windows-1250",  # Croatian
    "Translate/SK": "windows-1250",  # Slovak
    "Translate/SL": "windows-1250",  # Slovenian
    "Translate/EL": "windows-1253",  # Greek
    "Translate/BG": "windows-1251",  # Bulgarian
    "Translate/SR": "windows-1251",  # Serbian
    "Translate/HE": "windows-1255",  # Hebrew
    "Translate/AR": "windows-1256",  # Arabic
}
build_41_translate_path = 'media/lua/shared/Translate'
common_translate_path = 'common/media/lua/shared/Translate'

def render_jinja_template(source_file_path, destination_file_path, context):
    env = Environment(loader=FileSystemLoader(os.path.dirname(source_file_path)))
    template = env.get_template(os.path.basename(source_file_path))
    rendered_content = template.render(context)
    with open(destination_file_path, 'w') as destination_file:
        destination_file.write(rendered_content)

def render_jinja_template_from_string(template_string, context):
    env = Environment(loader=FileSystemLoader('.'))
    template = env.from_string(template_string)
    rendered_content = template.render(context)
    return rendered_content

def render_and_save_to_string(template_string, context, destination_file_path):
    rendered_content = render_jinja_template_from_string(template_string, context)
    with open(destination_file_path, 'w') as destination_file:
        destination_file.write(rendered_content)
    return rendered_content

def change_encoding(path, dest_encoding):
    if dest_encoding == 'utf-8':
        return
    with open(path, 'r', encoding='utf-8') as input_file:
        content = input_file.read()
    with open(path, 'w', encoding=dest_encoding) as output_file:
        output_file.write(content)

def copy_files(source_dir, destination_dir, context):
    if os.path.exists(destination_dir):
        shutil.rmtree(destination_dir)
    
    os.makedirs(destination_dir)

    for root, dirs, files in os.walk(source_dir):
        relative_path = os.path.relpath(root, source_dir)
        destination_path = os.path.join(destination_dir, relative_path)

        for dir_name in dirs:
            dir_path = os.path.join(destination_path, dir_name)
            os.makedirs(dir_path)

        for file_name in files:
            source_file_path = os.path.join(root, file_name)
            destination_file_path = os.path.join(destination_path, file_name)
            shutil.copy2(source_file_path, destination_file_path)

def transform_files(source_dir, destination_dir, context):
    if os.path.exists(destination_dir):
        shutil.rmtree(destination_dir)
    
    os.makedirs(destination_dir, exist_ok=True)

    for root, dirs, files in os.walk(source_dir):
        relative_path = os.path.relpath(root, source_dir)
        destination_path = os.path.join(destination_dir, relative_path)

        for dir_name in dirs:
            dir_path = os.path.join(destination_path, dir_name)
            os.makedirs(dir_path)

        for file_name in files:
            source_file_path = os.path.join(root, file_name)
            destination_file_path = os.path.join(destination_path, file_name)
            if file_name.endswith(('.lua', '.txt', '.info', '.md')):
                render_jinja_template(source_file_path, destination_file_path, context)
            else:
                shutil.copy2(source_file_path, destination_file_path)

    #Backport translation to build 41
    for root, dirs, files in os.walk(destination_dir):
        for file_name in files:
            file_path = os.path.join(root, file_name)
            if common_translate_path in file_path:
                dest_41_path = file_path.replace(common_translate_path,build_41_translate_path)
                os.makedirs(os.path.dirname(dest_41_path), exist_ok=True)
                shutil.copy2(file_path, dest_41_path)
                for encoding_key, encoding_value in build_41_encoding_map.items():
                    if encoding_key in dest_41_path:
                        change_encoding(dest_41_path, encoding_value)

def format_description(text):
    lines = text.split('\n')
    modified_lines = ['description=' + line for line in lines]
    modified_string = '<LINE>\n'.join(modified_lines)
    return modified_string

def format_workshop_description(text):
    lines = text.split('\n')
    modified_lines = ['description=' + line for line in lines]
    modified_string = '\n'.join(modified_lines)
    return modified_string

def format_workshop_txt(args):
    lines = []
    lines.append(f'version={args.MOD_VERSION}')
    lines.append(f'id={args.WORKSHOP_ID}')
    lines.append(f'title={args.MOD_NAME} (v{args.MOD_VERSION}) [B41 + B42]')
    lines.append(render_jinja_template_from_string(format_workshop_description(args.WORKSHOP_DESCRIPTION), vars(args)))
    lines.append(f'tags={args.WORKSHOP_TAGS}')
    lines.append(f'visibility={args.WORKSHOP_VISIBILITY}')
    return '\n'.join(lines)

def parse_arguments():
    parser = argparse.ArgumentParser(description="PZMod Builder Script")

    parser.add_argument("--MOD_ID", type=str, help="Mod ID", required=True)
    parser.add_argument("--MOD_NAME", type=str, help="Mod Name", required=True)
    parser.add_argument("--MOD_VERSION", type=str, help="Mod Version", required=True)
    parser.add_argument("--MOD_OPTIONS_VERSION", type=str, help="Mod Options Version", required=True)
    parser.add_argument("--MOD_POSTER_FILTER", type=str, help="Mod Poster Filter", required=False)
    parser.add_argument("--WORKSHOP_ID", type=str, help="Mod Workshop ID", required=True)
    parser.add_argument("--WORKSHOP_VISIBILITY", type=str, help="Mod Visibility", required=True)
    parser.add_argument("--WORKSHOP_DESCRIPTION", type=str, help="Workshop Description", required=True)
    parser.add_argument("--WORKSHOP_TAGS", type=str, help="Workshop TagLine", required=True)

    return parser.parse_args()

image_gen.generate_radial_progress("source/media/ui/lgd_antibodies_radial_progress.png")

args = parse_arguments()

try:
    with open(args.WORKSHOP_DESCRIPTION, 'r') as file:
        args.WORKSHOP_DESCRIPTION = file.read()
except Exception as e:
    args.WORKSHOP_DESCRIPTION = ""

try:
    with open(args.WORKSHOP_TAGS, 'r') as file:
        args.WORKSHOP_TAGS = file.read()
except Exception as e:
    args.WORKSHOP_TAGS = ""

transform_files('source', f'mods/{args.MOD_ID}', vars(args))

if args.MOD_POSTER_FILTER == "greyscale":
    image_gen.make_greyscale(f'mods/{args.MOD_ID}/poster.png')
    image_gen.make_greyscale(f'mods/{args.MOD_ID}/42.0/poster.png')

copy_files(f'mods/{args.MOD_ID}', f'workshop/{args.MOD_ID}/Contents/mods/{args.MOD_ID}', {})
image_gen.resize(f'mods/{args.MOD_ID}/poster.png', f'workshop/{args.MOD_ID}/preview.png', 256, 256)
    
try:
    with open(f'workshop/{args.MOD_ID}/workshop.txt', 'w') as file:
        file.write(format_workshop_txt(args))
except Exception as e:
    print(f"An error occurred: {e}")
