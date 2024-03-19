from io import BytesIO
import cairosvg
import math
from PIL import Image

def matrix_times(matrix, vector):
    a, b, c, d = matrix[0][0], matrix[0][1], matrix[1][0], matrix[1][1]
    x, y = vector[0], vector[1]
    return [a * x + b * y, c * x + d * y]

def rotate_matrix(angle):
    return [[math.cos(angle), -math.sin(angle)], [math.sin(angle), math.cos(angle)]]

def vec_add(v1, v2):
    return [v1[0] + v2[0], v1[1] + v2[1]]

def svg_ellipse_arc(center, radii, angles, rotation):
    """
    Returns an SVG path element that represents an ellipse arc.

    Parameters:
    - center: [cx, cy] - center of ellipse
    - radii: [rx, ry] - major and minor radii
    - angles: [start_angle, sweep_angle] - start angle in radians, and angle to sweep in radians (positive)
    - rotation: rotation of the whole ellipse in radians
    """
    angles[1] = angles[1] % (2 * math.pi)
    rot_matrix = rotate_matrix(rotation)

    start_point = vec_add(matrix_times(rot_matrix, [radii[0] * math.cos(angles[0]), radii[1] * math.sin(angles[0])]), center)
    end_point = vec_add(matrix_times(rot_matrix, [radii[0] * math.cos(angles[0] + angles[1]), radii[1] * math.sin(angles[0] + angles[1])]), center)

    flag_large_arc = 1 if angles[1] > math.pi else 0
    flag_sweep = 1 if angles[1] > 0 else 0

    path_data = f"M {start_point[0]} {start_point[1]} A {radii[0]} {radii[1]} {rotation / (2 * math.pi) * 360} {flag_large_arc} {flag_sweep} {end_point[0]} {end_point[1]}"
    return path_data

def generate_arc_svg(canvas_width, canvas_height, canvas_padding, stroke_width, color, start_angle, end_angle):
    width = canvas_width - stroke_width - canvas_padding
    height = canvas_height - stroke_width - canvas_padding

    caps = "butt" #"round", "square"
    #print(f"angle: ", math.fabs(end_angle - start_angle))

    if math.fabs(end_angle - start_angle) > 359.0:
        return f'''
        <svg width="{canvas_width}" height="{canvas_height}" xmlns="http://www.w3.org/2000/svg">
            <g fill="none" stroke="{color}" stroke-width="{stroke_width}" stroke-linecap="{caps}">
                <circle cx="{canvas_width / 2}" cy="{canvas_height / 2}" r="{width / 2}" />
            </g>
        </svg>
        '''
    else:
        path = svg_ellipse_arc([canvas_width / 2, canvas_height / 2], [width / 2, height / 2], [math.radians(start_angle - 90), math.radians(end_angle)], 0)
        contents = f'<path d="{path}" />'
        if end_angle == 0:
            contents = ""
        return f'''
        <svg width="{canvas_width}" height="{canvas_height}" xmlns="http://www.w3.org/2000/svg">
            <g fill="none" stroke="{color}" stroke-width="{stroke_width}" stroke-linecap="{caps}">
                {contents}
            </g>
        </svg>
        '''

def make_sprite(sprite_size, padding, thickness, angle):
    angle = max(0, min(angle, 359.999))
    temp_svg = generate_arc_svg(sprite_size[0], sprite_size[1], padding, thickness, "white", 0, angle)
    svg_buffer = BytesIO(temp_svg.encode('utf-8'))

    temp_png_buffer = BytesIO()
    cairosvg.svg2png(file_obj=svg_buffer, write_to=temp_png_buffer)

    temp_png_buffer.seek(0)
    image = Image.open(BytesIO(temp_png_buffer.getvalue()))
    return image

def compute_canvas_size(sprite_size, num_sprites):
    size = int(math.sqrt(num_sprites * sprite_size[0] * sprite_size[1]))
    canvas_size = [
        int(math.sqrt(num_sprites) * sprite_size[0]),
        int(math.sqrt(num_sprites) * sprite_size[1])
    ]
    modulo = [
        canvas_size[0] % sprite_size[0],
        canvas_size[1] % sprite_size[1]
    ]
    if modulo[0] != 0:
        canvas_size[0] += sprite_size[0] - modulo[0]
    if modulo[1] != 0:
        canvas_size[1] += sprite_size[1] - modulo[1]
    return canvas_size

def generate_radial_progress(out_path):
    sprite_size = [160, 160]
    sprite_padding = 2
    circle_thickness = 20
    num_sprites = 100

    canvas_size = compute_canvas_size(sprite_size, num_sprites)
    canvas = Image.new("RGBA", (canvas_size[0], canvas_size[1]), (0, 0, 0, 0))
    steps = [int(canvas_size[0] / sprite_size[0]), int(canvas_size[1] / sprite_size[1])]

    angle = 0
    angle_step = (360 / (num_sprites - 1))
    for y in range(steps[1]):
        for x in range(steps[0]):
            sprite = make_sprite(sprite_size, sprite_padding, circle_thickness, angle)
            canvas.paste(sprite, (x * sprite_size[0], y * sprite_size[1]), sprite)
            angle = angle + angle_step

    canvas.save(out_path)

def make_greyscale(input_path):
    img = Image.open(input_path)
    greyscale_img = img.convert("L")
    greyscale_img.save(input_path)

def resize(input_path, out_path, new_width, new_height):
    img = Image.open(input_path)
    resized_image = img.resize((new_width, new_height))
    resized_image.save(out_path)