<%@ Page Title="Công Cụ Chuẩn Hóa" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Tool.aspx.cs" Inherits="toolontaptn.Tool" ClientIDMode="Static" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .tool-wrapper { display: flex; flex-direction: column; height: calc(100vh - 100px); gap: 15px; }
        .toolbar { display: flex; gap: 10px; justify-content: flex-end; padding-bottom: 10px; border-bottom: 1px solid var(--border-color); flex-wrap: wrap; }
        
        .editor-container { display: flex; gap: 20px; flex: 1; min-height: 0; }
        .editor-box { flex: 1; display: flex; flex-direction: column; background: var(--bg-nav); border-radius: 12px; border: 1px solid var(--border-color); overflow: hidden; box-shadow: var(--shadow); }
        .editor-header { padding: 10px 15px; background: rgba(0,0,0,0.03); border-bottom: 1px solid var(--border-color); font-weight: 700; color: var(--text-muted); font-size: 13px; display: flex; gap: 8px; align-items: center; }
        
        .code-area { flex: 1; width: 100%; border: none; padding: 15px; resize: none; outline: none; background: var(--bg-body); color: var(--text-main); font-family: 'Consolas', monospace; font-size: 13px; line-height: 1.5; box-sizing: border-box; }
        .code-area:focus { background: var(--bg-nav); }

        .btn-tool { padding: 10px 16px; border-radius: 8px; border: none; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: 0.2s; font-size: 13px; }
        .btn-convert { background: var(--primary); color: white; }
        .btn-copy { background: #10b981; color: white; }
        .btn-transfer { background: linear-gradient(135deg, #f59e0b, #d97706); color: white; }
        .btn-tool:hover { transform: translateY(-2px); opacity: 0.9; }

        @media (max-width: 768px) {
            .editor-container { flex-direction: column; }
            .toolbar { justify-content: stretch; }
            .btn-tool { flex: 1; justify-content: center; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="MainContent" runat="server">
    <div class="tool-wrapper">
        <div class="toolbar">
             <button type="button" class="btn-tool btn-convert" onclick="convertData()"><i class="fa-solid fa-wand-magic-sparkles"></i> Chuẩn Hóa</button>
             <button type="button" class="btn-tool btn-copy" onclick="copyToClipboard()"><i class="fa-regular fa-copy"></i> Sao chép</button>
             <button type="button" class="btn-tool btn-transfer" onclick="transferToQuiz()"><i class="fa-solid fa-rocket"></i> Chuyển Thi</button>
        </div>

        <div class="editor-container">
            <div class="editor-box">
                <div class="editor-header"><i class="fa-solid fa-file-word"></i> DỮ LIỆU THÔ</div>
                <textarea id="input" class="code-area" placeholder="Dán đề thi copy từ Word/PDF vào đây..."></textarea>
            </div>
            <div class="editor-box">
                <div class="editor-header"><i class="fa-solid fa-file-code"></i> KẾT QUẢ</div>
                <textarea id="output" class="code-area" readonly placeholder="Kết quả chuẩn hóa..."></textarea>
            </div>
        </div>
    </div>

<script>
    // --- UTILS & CACHE ---
    const CACHE_KEY = 'tool_draft_input';
    
    const Toast = Swal.mixin({
        toast: true,
        position: 'top-end',
        showConfirmButton: false,
        timer: 2000,
        timerProgressBar: true
    });

    // --- 1. INIT & RESTORE SESSION ---
    document.addEventListener('DOMContentLoaded', () => {
        const inputEl = document.getElementById('input');
        
        // A. Phục hồi dữ liệu nếu F5
        const cached = sessionStorage.getItem(CACHE_KEY);
        if (cached) {
            inputEl.value = cached;
            // Tự động convert không cần thông báo để user thấy kết quả ngay
            convertData(false); 
        }

        // B. Lưu cache khi nhập liệu
        inputEl.addEventListener('input', function() {
            sessionStorage.setItem(CACHE_KEY, this.value);
        });
    });

    // --- 2. MAIN FUNCTIONS ---
    function convertData(showToast = true) {
        const raw = document.getElementById('input').value;
        const outputEl = document.getElementById('output');

        if(!raw.trim()) {
            outputEl.value = '';
            if(showToast) Toast.fire({ icon: 'info', title: 'Chưa có dữ liệu!' });
            return;
        }

        const lines = raw.split('\n');
        const result = lines.map(line => {
            let text = line.trim();
            if (!text) return '';
            
            // Regex bắt câu hỏi (1. hoặc 1) hoặc Câu 1:)
            const qMatch = text.match(/^(\d+)[\.\)]\s*(.*)/);
            if (qMatch) return `Câu ${qMatch[1]}: ${qMatch[2]}`;
            
            // Regex bắt đáp án (*a. hoặc A. hoặc a))
            const oMatch = text.match(/^(\*)?\s*([a-zA-Z])[\.\)]\s*(.*)/);
            if (oMatch) return `${oMatch[1] ? '*' : ''}${oMatch[2].toUpperCase()}. ${oMatch[3].trim()}`;
            
            return text;
        }).filter(l => l !== '').join('\n\n');
        
        outputEl.value = result;
        
        if(showToast) Toast.fire({ icon: 'success', title: 'Đã chuẩn hóa!' });
    }

    function copyToClipboard() {
        const out = document.getElementById('output');
        if(!out.value.trim()) return Toast.fire({ icon: 'warning', title: 'Không có nội dung!' });
        
        out.select(); document.execCommand('copy');
        Toast.fire({ icon: 'success', title: 'Đã sao chép!' });
    }

    function transferToQuiz() {
        // Convert lần cuối để đảm bảo dữ liệu mới nhất
        convertData(false); 
        const val = document.getElementById('output').value;
        
        if (!val.trim()) {
             Swal.fire({
                icon: 'error',
                title: 'Lỗi',
                text: 'Chưa có dữ liệu kết quả để chuyển!',
                confirmButtonColor: '#d33'
            });
            return;
        }
        
        // Lưu vào LocalStorage để trang Default đọc được
        localStorage.setItem('autoImportQuiz', val);
        
        // Hiệu ứng Loading chuyển trang
        let timerInterval
        Swal.fire({
          title: 'Đang chuyển hướng...',
          html: 'Vui lòng chờ trong giây lát.',
          timer: 800,
          timerProgressBar: true,
          didOpen: () => {
            Swal.showLoading()
          },
          willClose: () => {
            window.location.href = 'Default.aspx';
          }
        })
    }
</script>
</asp:Content>