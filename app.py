import tkinter as tk
import pyautogui as pag
from tkinter import filedialog
from PIL import Image, ImageTk
import Generate_Art

"""
画面構成
main_frame: 最初の画面。写真と絵を組み合わせて対象物を
"""

class App(tk.Tk):

    #画像選択時の処理
    def selectphoto(self,canvas,width,height, index):
        # ファイル選択の準備
        #jpg,png限定
        name = tk.filedialog.askopenfilename(title="ファイル選択", initialdir="C:/", filetypes=[("Image File","*.png"),("Image File","*.jpg")])
        
        ### 画像ロード
        image = Image.open(name)
        image = image.resize((int(width/4), int(height/4))) #画像を
        image = ImageTk.PhotoImage(image)
        if len(self.images[index])!=0:
            self.images[index].remove(self.images[index][0])
            self.transfer_images[index].remove(self.transfer_images[index][0])
        self.images[index].append((image, width/8*index+width/16, height/8))
        self.transfer_images[index].append(name)
        self.update_canvas(canvas,index)

    def update_canvas(self, canvas,index):
        canvas.delete(tk.ALL)
        for image, x, y in self.images[index]:
            canvas.create_image(x, y, image=image)

    def update_all_canvas(self):
        self.update_canvas(self.canvas)
        self.update_canvas(self.canvas2)
    
    def changeMainPage(self):
        self.frame1.destroy() #生成後の画面を消す
        self.mainPage() #ホーム画面に戻す

    def changeGeneratePage(self, content,style):
        '''
        画面遷移用の関数
        '''
        #画像２つ選択された場合
        if (self.images[0])!=0 and (self.images[1])!=0:
            self.main_frame.destroy()
            # ウィンドウの大きさを決定
            width = self.winfo_screenwidth()
            height = self.winfo_screenheight()
            Generate_Art.Generate(content,style)
            # 移動先フレーム作成
            self.frame1 = tk.Frame()
            self.frame1.grid(row=0, column=0, sticky="nsew")
            # タイトルラベル作成
            self.titleLabel = tk.Label(self.frame1, text="作った画像だよ！", font=('Helvetica', '35'))
            self.titleLabel.pack()
            self.back_button = tk.Button(self.frame1, text="戻る", command=lambda : self.changeMainPage())
            self.back_button.pack()
            canvas3 = tk.Canvas(self.frame1, width=width, height=height)
            canvas3.pack()
            self.image = Image.open("Output_Style_image.png")
            self.image = self.image.resize((500, 500))
            self.img_file = ImageTk.PhotoImage(self.image)
            canvas3.create_image(width/2, 500, image=self.img_file)
            
            self.frame1.tkraise()

    def mainPage(self):
        #左から写真, アートの順に準備
        self.images = [[],[]] #入力画像の表示を準備
        self.transfer_images = [[],[]] #入力画像のディレクトリ
        width = self.winfo_screenwidth()
        height = self.winfo_screenheight()
        # メインページフレーム作成
        self.main_frame = tk.Frame()
        self.main_frame.grid(row=0, column=0, sticky="nsew")
        # タイトルラベル作成
        self.titleLabel = tk.Label(self.main_frame, text="AI X ART", font=('Helvetica', '35'))
        self.titleLabel.pack()
        # フレーム1に移動するボタン
        ### ボタン作成・配置
        canvas = tk.Canvas(self.main_frame, width=width, height=height)
        button = tk.Button(self.main_frame, text="ファイル選択", command=lambda:self.selectphoto(canvas,width,height,0))
        button.place(x=width/4,y=400)
        canvas.place(x=width/8,y=500)

        canvas2 = tk.Canvas(self.main_frame, width=width, height=height)
        button2 = tk.Button(self.main_frame, text="ファイル選択", command=lambda:self.selectphoto(canvas2,width,height,1))
        button2.place(x=width/4*3,y=400)
        canvas2.place(x=width/8*5,y=500)
        self.back_button = tk.Button(self.main_frame, text="画像を作る", command=lambda : self.changeGeneratePage(self.transfer_images[0][0],self.transfer_images[1][0]))
        self.back_button.pack()
        #main_frameを一番上に表示
        self.main_frame.tkraise()        

    # 呪文
    def __init__(self, *args, **kwargs):
        tk.Tk.__init__(self, *args, **kwargs)

        # ウィンドウの大きさを決定
        width = self.winfo_screenwidth()
        height = self.winfo_screenheight()

        self.geometry(str(width)+"x"+str(height)+"+0+0")

        # ウィンドウのグリッドを 1x1 にする
        # この処理をコメントアウトすると配置がズレる
        self.grid_rowconfigure(0, weight=1)
        self.grid_columnconfigure(0, weight=1)
        
        self.mainPage()
        #main_frameを一番上に表示
        self.main_frame.tkraise()

if __name__ == "__main__":
    app = App()
    app.title("AI X ART")
    app.mainloop()
