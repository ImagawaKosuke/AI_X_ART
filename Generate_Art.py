import cv2
from rembg import remove
from PIL import Image
import numpy as np
import Style_Transfer

def remove_background(input_image_path, output_image_path):
    # 背景を削除
    try:
        input_image_path = Image.open(input_image_path)
    except IOError:
        print(f"Error: Cannot open {input_image_path}")
        return
    output_image = remove(input_image_path) #rembgの背景除去で写真の背景を削除
    output_image.save(output_image_path)

def apply_mask_to_background(masked_image_path):
    # RGBA画像を読み込み
    rgba_image = cv2.imread(masked_image_path, cv2.IMREAD_UNCHANGED)
    if rgba_image is None:
        print(f"Error: Cannot open {masked_image_path}")
        return

    # アルファチャネルをマスクとして使用
    alpha_channel = rgba_image[:, :, 3]

    # 白い背景画像を作成
    background = np.ones_like(rgba_image, dtype=np.uint8) * 255
    # マスクを適用
    background_masked = cv2.bitwise_and(background, background, mask=alpha_channel)
    return background_masked

def Generate(input_image,style_image):
    output_path = './output.png'

    # 背景除去処理
    remove_background(input_image, output_path)

    # マスク適用処理
    masked_image = apply_mask_to_background(output_path)
    if masked_image is not None:
        cv2.imwrite('masked_image.png', masked_image)
    Style_Transfer.Style_transfer(input_image,style_image)
    masked_image = cv2.imread("masked_image.png")
    output_style = cv2.imread("output_style.png", cv2.IMREAD_UNCHANGED)
    masked_image = cv2.resize(masked_image, (output_style.shape[1], output_style.shape[0])) #横, 縦
    #マスク画像を反転
    masked_background = cv2.bitwise_not(masked_image)
    input = cv2.imread(input_image, cv2.IMREAD_UNCHANGED)
    input = cv2.resize(input, (masked_background.shape[1], masked_background.shape[0])) #横, 縦
    
    dst = cv2.bitwise_and(output_style, masked_image)
    dst2 = cv2.bitwise_and(input, masked_background)
    result = cv2.bitwise_or(dst, dst2)
    cv2.imwrite("Output_Style_image.png",result)



