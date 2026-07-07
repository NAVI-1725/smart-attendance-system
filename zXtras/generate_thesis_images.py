from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import math
import os

OUT = Path("thesis_recreated_images")
OUT.mkdir(exist_ok=True)

W, H = 1600, 900
BG = "white"
FG = "black"
GRAY = (80, 80, 80)

def get_font(size, bold=False):
    candidates = [
        r"C:\Windows\Fonts\arialbd.ttf" if bold else r"C:\Windows\Fonts\arial.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for p in candidates:
        if os.path.exists(p):
            return ImageFont.truetype(p, size=size)
    return ImageFont.load_default()

TITLE = get_font(42, True)
SUB = get_font(24, False)
BOX = get_font(24, False)
BOX_B = get_font(24, True)
SM = get_font(20, False)

def draw_centered(draw, xy, text, font, fill=FG, max_width=None, line_spacing=8):
    x, y = xy
    lines = [text]
    if max_width:
        words = text.split()
        lines, cur = [], ""
        for w in words:
            t = (cur + " " + w).strip()
            if draw.textbbox((0, 0), t, font=font)[2] <= max_width:
                cur = t
            else:
                if cur:
                    lines.append(cur)
                cur = w
        if cur:
            lines.append(cur)
    heights = [draw.textbbox((0, 0), ln, font=font)[3] for ln in lines]
    total_h = sum(heights) + line_spacing * (len(lines) - 1)
    cy = y - total_h / 2
    for ln, h in zip(lines, heights):
        bbox = draw.textbbox((0, 0), ln, font=font)
        tw = bbox[2] - bbox[0]
        draw.text((x - tw / 2, cy), ln, font=font, fill=fill)
        cy += h + line_spacing

def rect(draw, box, text, font=BOX, title=False):
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=20, outline=FG, width=4, fill=(248, 248, 248))
    draw_centered(draw, ((x1 + x2) // 2, (y1 + y2) // 2), text, BOX_B if title else font, max_width=(x2 - x1) - 30)

def arrow(draw, p1, p2, width=4):
    draw.line([p1, p2], fill=FG, width=width)
    ang = math.atan2(p2[1] - p1[1], p2[0] - p1[0])
    ah = 14
    for da in (math.pi / 7, -math.pi / 7):
        x = p2[0] - ah * math.cos(ang + da)
        y = p2[1] - ah * math.sin(ang + da)
        draw.line([p2, (x, y)], fill=FG, width=width)

def base(title, subtitle=None):
    img = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(img)
    d.rectangle([20, 20, W - 20, H - 20], outline=FG, width=4)
    draw_centered(d, (W // 2, 60), title, TITLE)
    if subtitle:
        draw_centered(d, (W // 2, 105), subtitle, SUB)
    return img, d

def save(img, name):
    path = OUT / name
    img.save(path, quality=95)
    print(f"Saved: {path}")

# 1) fig1_1_methodology.png
img, d = base("Research Methodology")
steps = [
    "Problem Identification",
    "Literature Review",
    "Requirement Analysis",
    "System Design & Implementation",
    "Testing, Validation & Evaluation",
]
x_positions = [160, 460, 760, 1060, 1360]
for x, txt in zip(x_positions, steps):
    rect(d, [x - 110, 320, x + 110, 450], txt)
for i in range(len(x_positions) - 1):
    arrow(d, (x_positions[i] + 110, 385), (x_positions[i + 1] - 110, 385))
draw_centered(d, (W // 2, 550), "Sequential methodology used for HKS ATTENDANCE", SUB)
save(img, "fig1_1_methodology.png")

# 2) fig1_2_contributions.png
img, d = base("Research Contributions of HKS ATTENDANCE")
center = [620, 310, 980, 480]
rect(d, center, "HKS ATTENDANCE", title=True)
contribs = [
    ("Multi-Evidence\nVerification", [120, 130, 420, 260]),
    ("BLE + GPS\nFusion", [1180, 130, 1480, 260]),
    ("Device\nBinding", [120, 560, 420, 690]),
    ("Faculty Review\nWorkflow", [1180, 560, 1480, 690]),
    ("Claims & Appeals", [470, 650, 770, 780]),
    ("Replay Protection\n& HMAC Security", [830, 650, 1130, 780]),
]
for txt, box in contribs:
    rect(d, box, txt)
    cx = (box[0] + box[2]) // 2
    cy = (box[1] + box[3]) // 2
    ccx = (center[0] + center[2]) // 2
    ccy = (center[1] + center[3]) // 2
    arrow(d, (cx, cy), (ccx, ccy))
save(img, "fig1_2_contributions.png")

# 3) fig1_3_research_design.png
img, d = base("Research Design Pipeline")
steps = [
    "Problem Identification",
    "Requirement Analysis",
    "Architecture Design",
    "Implementation",
    "Validation",
    "Evaluation",
]
y = 160
for i, s in enumerate(steps):
    rect(d, [560, y, 1040, y + 85], s)
    if i < len(steps) - 1:
        arrow(d, (800, y + 85), (800, y + 125))
    y += 125
save(img, "fig1_3_research_design.png")

# 4) fig2_1_evolution.png
img, d = base("Evolution of Attendance Systems")
items = [
    ("Manual Register", "Proxy attendance"),
    ("RFID", "Card sharing"),
    ("QR Code", "Screenshot forwarding"),
    ("GPS-Based", "Poor indoor precision"),
    ("BLE-Based", "Replay / spoof risk"),
    ("HKS ATTENDANCE", "Multi-evidence + governance"),
]
xs = [120, 370, 620, 870, 1120, 1370]
for x, (a, b) in zip(xs, items):
    rect(d, [x - 105, 300, x + 105, 470], f"{a}\n\n{b}")
for i in range(len(xs) - 1):
    arrow(d, (xs[i] + 105, 385), (xs[i + 1] - 105, 385))
save(img, "fig2_1_evolution.png")

# 5) fig3_2_requirements.png
img, d = base("Functional and Non-Functional Requirements Overview")
rect(d, [120, 230, 520, 630],
     "Functional Requirements\n\n• Authentication\n• Device Binding\n• Session Discovery\n• BLE + GPS Submission\n• Faculty Review\n• Claims Workflow\n• Admin Governance")
rect(d, [1080, 230, 1480, 630],
     "Non-Functional Requirements\n\n• Performance\n• Security\n• Reliability\n• Scalability\n• Usability")
rect(d, [610, 330, 990, 530], "HKS ATTENDANCE\nRequirements", title=True)
arrow(d, (520, 430), (610, 430))
arrow(d, (990, 430), (1080, 430))
save(img, "fig3_2_requirements.png")

# 6) fig4_5_evidence_fusion.png
img, d = base("Evidence Fusion Flow")
rect(d, [100, 300, 420, 470], "BLE Evidence\n\nBeacon ID\nNonce\nTimestamp\nSignature")
rect(d, [100, 560, 420, 730], "GPS Evidence\n\nLatitude\nLongitude\nAccuracy\nDistance")
rect(d, [610, 380, 990, 650], "Evidence Fusion Engine\n\nValidate BLE\nValidate GPS\nCombine outcomes")
rect(d, [1180, 380, 1500, 650], "Decision\n\nCONFIRMED\nFLAGGED\nREJECTED")
arrow(d, (420, 385), (610, 450))
arrow(d, (420, 645), (610, 580))
arrow(d, (990, 515), (1180, 515))
save(img, "fig4_5_evidence_fusion.png")

# 7) fig4_7_sequence_diagram.png
img, d = base("Sequence Diagram — Attendance Submission")
actors = ["Student", "Flutter App", "Backend API", "BLE Validator", "GPS Validator", "Database"]
xs = [110, 350, 590, 860, 1110, 1400]
for x, a in zip(xs, actors):
    draw_centered(d, (x, 150), a, BOX_B)
    d.line([(x, 180), (x, 780)], fill=GRAY, width=2)
msgs = [
    (0, 1, 220, "Login / Select Session"),
    (1, 3, 300, "Scan beacon payload"),
    (1, 4, 380, "Capture location"),
    (1, 2, 470, "Submit attendance"),
    (2, 3, 540, "Validate BLE"),
    (2, 4, 610, "Validate GPS"),
    (2, 5, 690, "Persist decision"),
    (2, 1, 760, "Return status"),
]
for s, t, y, txt in msgs:
    x1, x2 = xs[s], xs[t]
    arrow(d, (x1, y), (x2, y))
    draw_centered(d, ((x1 + x2) // 2, y - 18), txt, SM)
save(img, "fig4_7_sequence_diagram.png")

# 8) fig4_8_status_state.png
img, d = base("Attendance Status State Diagram")
states = [
    ("PENDING", [120, 360, 360, 470]),
    ("CONFIRMED", [480, 210, 760, 320]),
    ("FLAGGED", [480, 500, 760, 610]),
    ("REJECTED", [930, 360, 1210, 470]),
    ("CLAIMED", [1240, 210, 1500, 320]),
]
for txt, b in states:
    rect(d, b, txt, title=True)
arrow(d, (360, 415), (480, 265))
arrow(d, (360, 415), (480, 555))
arrow(d, (760, 555), (930, 415))
arrow(d, (1210, 415), (1240, 265))
save(img, "fig4_8_status_state.png")

# 9) fig4_9_security_architecture.png
img, d = base("Security Architecture — Checkpoint Pipeline")
steps = [
    "Student Device",
    "JWT Authentication",
    "Backend API",
    "BLE Validation",
    "GPS Validation",
    "Decision Engine",
    "Faculty Review\n(for FLAGGED records)",
    "PostgreSQL + Audit Log",
]
y = 145
for i, s in enumerate(steps):
    rect(d, [540, y, 1060, y + 72], s)
    if i < len(steps) - 1:
        arrow(d, (800, y + 72), (800, y + 110))
    y += 110
save(img, "fig4_9_security_architecture.png")

# 10) fig4_10_dfd_level0.png
img, d = base("Data Flow Diagram — Level 0")
rect(d, [640, 260, 960, 560], "HKS ATTENDANCE\nSystem", title=True)
entities = [
    ("Student", [120, 300, 380, 450]),
    ("Faculty", [1220, 200, 1480, 350]),
    ("Administrator", [1220, 470, 1480, 620]),
]
for name, box in entities:
    rect(d, box, name)
arrow(d, (380, 360), (640, 360))
draw_centered(d, (510, 330), "Attendance / Claims", SM)
arrow(d, (960, 310), (1220, 270))
draw_centered(d, (1090, 240), "Review / Session actions", SM)
arrow(d, (960, 510), (1220, 545))
draw_centered(d, (1090, 575), "Governance / CRUD", SM)
save(img, "fig4_10_dfd_level0.png")

# 11) fig4_11_component_diagram.png
img, d = base("Backend Component Diagram")
boxes = {
    "Routers": [120, 170, 420, 290],
    "Services": [520, 170, 820, 290],
    "Security": [920, 170, 1220, 290],
    "Repositories": [320, 470, 620, 590],
    "PostgreSQL": [980, 470, 1280, 590],
}
for k, b in boxes.items():
    rect(d, b, k, title=True)
rect(d, [120, 340, 420, 430], "Auth / Attendance /\nFaculty / Admin APIs")
rect(d, [520, 340, 820, 430], "Attendance / Claims /\nFaculty / Admin services")
rect(d, [920, 340, 1220, 430], "JWT / Device / BLE /\nGPS validators")
arrow(d, (420, 230), (520, 230))
arrow(d, (820, 230), (920, 230))
arrow(d, (670, 290), (470, 470))
arrow(d, (1070, 290), (1130, 470))
arrow(d, (620, 530), (980, 530))
save(img, "fig4_11_component_diagram.png")

# 12) fig4_12_package_diagram.png
img, d = base("Flutter Package Diagram")
cols = [
    ("core\n(api, auth, services)", [140, 250, 440, 450]),
    ("features/attendance", [500, 180, 840, 330]),
    ("features/faculty", [500, 380, 840, 530]),
    ("features/claims", [900, 180, 1240, 330]),
    ("features/admin", [900, 380, 1240, 530]),
]
for txt, b in cols:
    rect(d, b, txt)
arrow(d, (440, 350), (500, 255))
arrow(d, (440, 350), (500, 455))
arrow(d, (840, 255), (900, 255))
arrow(d, (840, 455), (900, 455))
save(img, "fig4_12_package_diagram.png")

# 13) fig8_1_feature_coverage.png
img, d = base("Feature Coverage Summary")
features = [
    "Authentication",
    "Device Binding",
    "BLE Evidence",
    "GPS Evidence",
    "Faculty Review",
    "Claims Workflow",
    "Admin Governance",
    "Audit Logging",
]
x1 = 180
y = 170
for i, f in enumerate(features):
    rect(d, [x1, y + i * 78, 860, y + i * 78 + 58], f)
    draw_centered(d, (1140, y + i * 78 + 29), "Implemented", BOX_B)
save(img, "fig8_1_feature_coverage.png")

# 14) fig8_2_security_verification.png
img, d = base("Security Verification Summary")
tests = [
    "JWT auth enforcement",
    "Device binding enforcement",
    "Trusted beacon validation",
    "Nonce freshness check",
    "Replay prevention",
    "Faculty role checks",
    "Audit log persistence",
]
for i, t in enumerate(tests):
    y = 180 + i * 82
    rect(d, [150, y, 980, y + 58], t)
    rect(d, [1100, y, 1380, y + 58], "PASS")
save(img, "fig8_2_security_verification.png")

# 15) fig8_3_decision_distribution.png
img, d = base("Attendance Decision Distribution")
d.line([(180, 720), (1420, 720)], fill=FG, width=4)
d.line([(180, 180), (180, 720)], fill=FG, width=4)
bars = [("Confirmed", 650), ("Flagged", 360), ("Rejected", 220)]
xs = [420, 760, 1100]
for x, (label, h) in zip(xs, bars):
    d.rectangle([x - 90, 720 - h, x + 90, 720], outline=FG, width=4, fill=(230, 230, 230))
    draw_centered(d, (x, 750), label, BOX_B)
save(img, "fig8_3_decision_distribution.png")

# 16) fig8_4_testing_summary.png
img, d = base("Testing Summary")
cats = ["Functional", "Security", "Database", "Workflow", "API"]
vals = ["PASS", "PASS", "PASS", "PASS", "PASS"]
for i, (c, v) in enumerate(zip(cats, vals)):
    y = 220 + i * 95
    rect(d, [220, y, 760, y + 62], c)
    rect(d, [940, y, 1240, y + 62], v)
save(img, "fig8_4_testing_summary.png")

# 17) claims_flow.png
img, d = base("Claims Resolution Workflow")
steps = [
    "Rejected Attendance",
    "Student Submits Claim",
    "Faculty Reviews Evidence",
    "Faculty Approves / Rejects Claim",
    "Audit Log Updated",
]
xs = [150, 450, 800, 1150, 1450]
for x, s in zip(xs, steps):
    rect(d, [x - 110, 340, x + 110, 500], s)
for i in range(len(xs) - 1):
    arrow(d, (xs[i] + 110, 420), (xs[i + 1] - 110, 420))
save(img, "claims_flow.png")

print("\nAll recreated images saved in:", OUT.resolve())