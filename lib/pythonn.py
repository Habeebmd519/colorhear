from PIL import Image
import os

# Define the colors you want to generate (color name + RGB value)
colors = {
    'Red': (255, 0, 0),
    'Green': (0, 255, 0),
    'Blue': (0, 0, 255),
    'Yellow': (255, 255, 0),
    'Orange': (255, 165, 0),
    'Purple': (128, 0, 128),
    'Pink': (255, 192, 203),
    'Black': (0, 0, 0),
    'White': (255, 255, 255),
    'Brown': (139, 69, 19)
}

# Number of images per color
num_images = 50

# Output directory
output_dir = "colors_dataset"
os.makedirs(output_dir, exist_ok=True)

# Generate images
for color_name, rgb in colors.items():
    color_dir = os.path.join(output_dir, color_name)
    os.makedirs(color_dir, exist_ok=True)
    
    for i in range(num_images):
        img = Image.new('RGB', (100, 100), rgb)
        filename = f"{color_name.lower()}_{i+1}.jpg"
        img.save(os.path.join(color_dir, filename))

print("✅ Color images generated successfully!")
