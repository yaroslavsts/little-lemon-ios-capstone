from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import html

root = Path(__file__).resolve().parent
image = Image.new('RGB', (1000, 1320), 'white')
draw = ImageDraw.Draw(image)
font_path = '/System/Library/Fonts/Supplemental/Arial.ttf'
font = lambda size: ImageFont.truetype(font_path, size)
svg = ['<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="1320" viewBox="0 0 1000 1320">', '<rect width="1000" height="1320" fill="white"/>']

def box(x, y, w, h, fill='#ffffff', radius=0, stroke='#495e57'):
    draw.rounded_rectangle((x,y,x+w,y+h), radius, fill=fill, outline=stroke, width=2)
    svg.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{radius}" fill="{fill}" stroke="{stroke}" stroke-width="2"/>')

def text(x, y, value, size=20, color='#333333'):
    draw.text((x,y), value, fill=color, font=font(size))
    svg.append(f'<text x="{x}" y="{y+size}" fill="{color}" font-family="Arial, sans-serif" font-size="{size}">{html.escape(value)}</text>')

def line(x1,y1,x2,y2,color='#aaaaaa'):
    draw.line((x1,y1,x2,y2), fill=color, width=2)
    svg.append(f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{color}" stroke-width="2"/>')

text(60,35,'Little Lemon · Home wireframe',34)
text(60,83,'iOS App Capstone | screen structure and navigation',20,'#666666')
box(60,140,430,1090,radius=36,stroke='#222222')
text(87,166,'9:41',16);text(374,166,'Wi-Fi   100%',13)
box(82,211,280,62,fill='#edefee',radius=8)
text(139,230,'LITTLE LEMON',20)
box(391,219, 50,50,fill='#edefee',radius=25);text(401,233,'AM',18)
box(82,291,386,328,fill='#f1f3f2')
text(102,310,'Little Lemon',36);text(102,356,'Chicago',26)
text(102,404,'Family owned',18);text(102,435,'Mediterranean',18);text(102,466,'restaurant description',16)
box(338,399,109,123,fill='#dddddd',radius=10)
line(338,399,447,522);line(447,399,338,522);text(357,448,'PHOTO',14)
box(102,551,344,46,fill='white',radius=8);text(121,565,'Search dishes…',17,'#666666')
text(101,646,'ORDER FOR DELIVERY!',20)
for x,w,label in [(101,51,'All'),(163,85,'Starters'),(260,69,'Mains'),(342,98,'Desserts')]:
    box(x,688,w,36,fill='#edefee',radius=18);text(x+10,699,label,13)
text(106,738,'← Scroll categories to see Drinks →',13,'#777777')
for y,name,desc in [(783,'Bruschetta','Oven baked bruschetta…'),(919,'Greek Salad','Fresh salad description…'),(1055,'Grilled Fish','Menu description…')]:
    text(102,y,name,22);text(102,y+38,desc,15,'#777777');text(102,y+69,'$10.00',18)
    box(356,y,90,90,fill='#dddddd',radius=8);line(356,y,446,y+90);line(446,y,356,y+90)
    line(101,y+116,448,y+116)

for y,title,detail in [
    (230,'1 · Header','Logo and profile button'),
    (420,'2 · Hero','Restaurant, description and image'),
    (565,'Search','Filters dish names as you type'),
    (688,'3 · Menu breakdown','Selectable category chips'),
    (919,'4 · Food menu list','Name, summary, price and photo')]:
    line(490,y+15,548,y+15,'#495e57');text(565,y,title,24);text(565,y+39,detail,18,'#666666')
text(565,1060,'Navigation',24)
text(565,1100,'Profile button → editable profile',18)
text(565,1133,'Dish row → details and order alert',18)
text(565,1166,'Back returns to the previous screen',18)
text(60,1260,'Layout reference for the implemented SwiftUI Home screen.',19,'#666666')
svg.append('</svg>')
(root/'Home-Wireframe.svg').write_text('\n'.join(svg))
image.save(root/'Home-Wireframe.jpg',quality=95)
