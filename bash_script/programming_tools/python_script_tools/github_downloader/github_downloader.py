import os
import requests
import tkinter as tk
from tkinter import ttk, messagebox, filedialog
from threading import Thread

class GitHubDownloaderGUI:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("GitHub Downloader")
        self.root.geometry("700x420")
        self.root.resizable(True, True)
        
        self.create_widgets()
        
    def create_widgets(self):
        # Tiêu đề
        title = tk.Label(self.root, text="GitHub Public Downloader", font=("Arial", 16, "bold"))
        title.pack(pady=10)
        
        # URL
        tk.Label(self.root, text="Link GitHub:", font=("Arial", 10)).pack(anchor="w", padx=20)
        self.url_entry = tk.Entry(self.root, width=80, font=("Arial", 10))
        self.url_entry.pack(pady=5, padx=20, ipady=4)
        self.url_entry.insert(0, "https://github.com/")
        
        # Output folder
        tk.Label(self.root, text="Thư mục lưu:", font=("Arial", 10)).pack(anchor="w", padx=20)
        folder_frame = tk.Frame(self.root)
        folder_frame.pack(pady=5, padx=20, fill="x")
        
        self.folder_entry = tk.Entry(folder_frame, font=("Arial", 10))
        self.folder_entry.pack(side="left", fill="x", expand=True)
        self.folder_entry.insert(0, os.getcwd())
        
        tk.Button(folder_frame, text="Chọn...", command=self.choose_folder).pack(side="right", padx=(5,0))
        
        # Progress
        self.progress = ttk.Progressbar(self.root, mode='indeterminate')
        self.progress.pack(pady=15, padx=20, fill="x")
        
        # Log
        tk.Label(self.root, text="Log:", font=("Arial", 10)).pack(anchor="w", padx=20)
        self.log_text = tk.Text(self.root, height=12, font=("Consolas", 9))
        self.log_text.pack(pady=5, padx=20, fill="both", expand=True)
        
        # Button
        btn_frame = tk.Frame(self.root)
        btn_frame.pack(pady=15)
        
        self.download_btn = tk.Button(btn_frame, text="📥 TẢI XUỐNG", font=("Arial", 11, "bold"),
                                    bg="#238636", fg="white", padx=20, pady=8,
                                    command=self.start_download)
        self.download_btn.pack(side="left", padx=10)
        
        tk.Button(btn_frame, text="Xóa Log", command=self.clear_log).pack(side="left", padx=10)
        
    def log(self, message):
        self.log_text.insert(tk.END, message + "\n")
        self.log_text.see(tk.END)
        self.root.update()
        
    def choose_folder(self):
        folder = filedialog.askdirectory()
        if folder:
            self.folder_entry.delete(0, tk.END)
            self.folder_entry.insert(0, folder)
            
    def clear_log(self):
        self.log_text.delete(1.0, tk.END)
        
    def start_download(self):
        url = self.url_entry.get().strip()
        output_dir = self.folder_entry.get().strip()
        
        if not url or "github.com" not in url:
            messagebox.showerror("Lỗi", "Vui lòng nhập link GitHub hợp lệ!")
            return
        
        self.download_btn.config(state="disabled")
        self.progress.start()
        self.log("🔄 Đang bắt đầu tải...")
        
        # Chạy trong thread để không bị treo GUI
        Thread(target=self.download_thread, args=(url, output_dir), daemon=True).start()
        
    def download_thread(self, url, output_dir):
        try:
            result = self.download_github_content(url, output_dir)
            if result:
                self.log("✅ Hoàn thành tải xuống!")
                messagebox.showinfo("Thành công", "Đã tải xong!")
        except Exception as e:
            self.log(f"❌ Lỗi: {str(e)}")
            messagebox.showerror("Lỗi", str(e))
        finally:
            self.download_btn.config(state="normal")
            self.progress.stop()
            
    # === Hàm tải chính (đã tối ưu cho GUI) ===
    def download_github_content(self, url, output_dir="."):
        # (Giống code trước, mình rút gọn một chút)
        import re
        from urllib.parse import urlparse
        
        parsed = urlparse(url)
        path_parts = parsed.path.strip('/').split('/')
        
        if len(path_parts) < 2:
            raise ValueError("Link GitHub không hợp lệ")
        
        owner = path_parts[0]
        repo = path_parts[1]
        
        # Xác định branch và path
        if len(path_parts) > 3 and path_parts[2] in ['blob', 'tree']:
            branch = path_parts[3]
            item_path = '/'.join(path_parts[4:])
        else:
            branch = "main"
            item_path = '/'.join(path_parts[2:])
        
        os.makedirs(output_dir, exist_ok=True)
        
        api_url = f"https://api.github.com/repos/{owner}/{repo}/contents/{item_path}?ref={branch}"
        
        headers = {"User-Agent": "GitHub-Downloader-GUI"}
        resp = requests.get(api_url, headers=headers)
        
        if resp.status_code != 200:
            raise Exception(f"Lỗi {resp.status_code}: {resp.text}")
        
        data = resp.json()
        
        if isinstance(data, dict):  # File
            filepath = os.path.join(output_dir, data['name'])
            self.log(f"📄 Đang tải file: {data['name']}")
            self.download_file(data['download_url'], filepath)
        else:  # Folder
            self.log(f"📁 Đang tải folder: {item_path or 'root'}")
            self.download_folder(data, output_dir, owner, repo, branch)
            
        return True
    
    def download_file(self, url, filepath):
        resp = requests.get(url, stream=True)
        with open(filepath, 'wb') as f:
            for chunk in resp.iter_content(chunk_size=8192):
                f.write(chunk)
        self.log(f"✅ Đã tải: {os.path.basename(filepath)}")
        
    def download_folder(self, items, base_dir, owner, repo, branch):
        for item in items:
            local_path = os.path.join(base_dir, item['name'])
            
            if item['type'] == 'file':
                os.makedirs(os.path.dirname(local_path), exist_ok=True)
                self.log(f"📄 Đang tải: {item['path']}")
                self.download_file(item['download_url'], local_path)
                
            elif item['type'] == 'dir':
                self.log(f"📁 Tạo folder: {item['name']}")
                os.makedirs(local_path, exist_ok=True)
                
                # Lấy nội dung folder con
                api_url = f"https://api.github.com/repos/{owner}/{repo}/contents/{item['path']}?ref={branch}"
                resp = requests.get(api_url)
                if resp.status_code == 200:
                    self.download_folder(resp.json(), local_path, owner, repo, branch)

    def run(self):
        self.root.mainloop()


# ====================== CHẠY CHƯƠNG TRÌNH ======================
if __name__ == "__main__":
    app = GitHubDownloaderGUI()
    app.run()
