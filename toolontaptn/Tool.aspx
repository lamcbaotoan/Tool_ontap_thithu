<%@ Page Title="Công Cụ Chuẩn Hóa" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Tool.aspx.cs" Inherits="toolontaptn.Tool" ClientIDMode="Static" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/mammoth/1.6.0/mammoth.browser.min.js"></script>

    <style>
        .tool-wrapper { display: flex; flex-direction: column; height: calc(100vh - 100px); gap: 15px; }
        .toolbar { display: flex; gap: 10px; justify-content: flex-end; padding-bottom: 10px; border-bottom: 1px solid var(--border-color); flex-wrap: wrap; }
        
        .editor-container { display: flex; gap: 20px; flex: 1; min-height: 0; }
        .editor-box { flex: 1; display: flex; flex-direction: column; background: var(--bg-nav); border-radius: 12px; border: 1px solid var(--border-color); overflow: hidden; box-shadow: var(--shadow); }
        .editor-header { padding: 10px 15px; background: rgba(0,0,0,0.03); border-bottom: 1px solid var(--border-color); font-weight: 700; color: var(--text-muted); font-size: 13px; display: flex; gap: 8px; align-items: center; justify-content: space-between; }
        
        .code-area { flex: 1; width: 100%; border: none; padding: 15px; resize: none; outline: none; background: var(--bg-body); color: var(--text-main); font-family: 'Consolas', monospace; font-size: 13px; line-height: 1.5; box-sizing: border-box; }
        .code-area:focus { background: var(--bg-nav); }

        .btn-tool { padding: 10px 16px; border-radius: 8px; border: none; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: 0.2s; font-size: 13px; }
        .btn-import { background: #6366f1; color: white; }
        .btn-convert { background: var(--primary); color: white; }
        .btn-copy { background: #10b981; color: white; }
        .btn-transfer { background: linear-gradient(135deg, #f59e0b, #d97706); color: white; }
        .btn-tool:hover { transform: translateY(-2px); opacity: 0.9; }
        
        .loading-overlay { position: absolute; inset: 0; background: rgba(255,255,255,0.8); display: flex; align-items: center; justify-content: center; z-index: 10; font-weight: bold; color: var(--primary); backdrop-filter: blur(2px); border-radius: 12px; }
        .badge-count { background: rgba(0,0,0,0.1); padding: 2px 8px; border-radius: 4px; font-size: 11px; color: var(--primary); }

        @media (max-width: 768px) {
            .editor-container { flex-direction: column; }
            .toolbar { justify-content: stretch; }
            .btn-tool { flex: 1; justify-content: center; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="tool-wrapper">
        <div class="toolbar">
             <input type="file" id="fileUpload" accept=".txt,.docx" style="display: none;" onchange="handleFileUpload(this)">
             
             <button type="button" class="btn-tool btn-import" onclick="document.getElementById('fileUpload').click()">
                 <i class="fa-solid fa-file-import"></i> Nhập File (Word/TXT)
             </button>

             <div style="flex:1"></div> 
             <button type="button" class="btn-tool btn-convert" onclick="openConvertOption()"><i class="fa-solid fa-wand-magic-sparkles"></i> Chuẩn Hóa</button>
             <button type="button" class="btn-tool btn-copy" onclick="copyToClipboard()"><i class="fa-regular fa-copy"></i> Sao chép</button>
             <button type="button" class="btn-tool btn-transfer" onclick="transferToQuiz()"><i class="fa-solid fa-rocket"></i> Chuyển Thi</button>
        </div>

        <div class="editor-container">
            <div class="editor-box" style="position:relative">
                <div class="editor-header">
                    <div style="display:flex; gap:8px; align-items:center;">
                        <span><i class="fa-solid fa-file-word"></i> DỮ LIỆU THÔ</span>
                        <span id="input-stats" class="badge-count" style="display:none">0 câu</span>
                    </div>
                    <span id="file-info" style="font-weight:400; font-size:11px; color:#888;"></span>
                </div>
                <textarea id="input" class="code-area" placeholder="Dán văn bản hoặc bấm 'Nhập File' để tải lên Word/TXT..."></textarea>
                <div id="loading-input" class="loading-overlay" style="display:none;">
                    <i class="fa-solid fa-spinner fa-spin" style="margin-right:10px;"></i> Đang đọc file...
                </div>
            </div>
            <div class="editor-box">
                <div class="editor-header">
                    <span><i class="fa-solid fa-file-code"></i> KẾT QUẢ</span>
                    <span id="output-stats" class="badge-count" style="display:none">0 câu</span>
                </div>
                <textarea id="output" class="code-area" readonly placeholder="Kết quả chuẩn hóa sẽ hiện ở đây..."></textarea>
            </div>
        </div>
    </div>

<script>
    const CACHE_KEY = 'tool_draft_input';
    const Toast = Swal.mixin({
        toast: true, position: 'top-end', showConfirmButton: false, timer: 2000, timerProgressBar: true
    });

    document.addEventListener('DOMContentLoaded', () => {
        const inputEl = document.getElementById('input');
        const cached = sessionStorage.getItem(CACHE_KEY);
        if (cached) {
            inputEl.value = cached;
            updateStats('input', cached);
            // Không tự động convert nữa để người dùng chọn option
        }
        inputEl.addEventListener('input', function () {
            sessionStorage.setItem(CACHE_KEY, this.value);
            updateStats('input', this.value);
        });
    });

    // --- HÀM ĐẾM (Đã tinh chỉnh Regex chặt hơn để tránh đếm sai) ---
    function updateStats(type, text) {
        let count = 0;
        if (type === 'input') {
            // Chỉ đếm dòng bắt đầu bằng "Câu X" hoặc "X." nhưng phải có nội dung phía sau
            // Tránh trường hợp chỉ có số "123" đứng một mình
            const regex = /^(?:c[âa]u\s*)?\d+[\.\:\)\s]\s*\S+/gim;
            count = (text.match(regex) || []).length;
            const el = document.getElementById('input-stats');
            el.innerText = `${count} câu tiềm năng`;
            el.style.display = count > 0 ? 'inline-block' : 'none';
        } else {
            const regex = /^Câu\s+\d+:/gm;
            count = (text.match(regex) || []).length;
            const el = document.getElementById('output-stats');
            el.innerText = `${count} câu`;
            el.style.display = count > 0 ? 'inline-block' : 'none';
        }
    }

    async function handleFileUpload(input) {
        const file = input.files[0];
        if (!file) return;
        input.value = '';

        const loader = document.getElementById('loading-input');
        const inputArea = document.getElementById('input');
        const fileInfo = document.getElementById('file-info');

        loader.style.display = 'flex';
        fileInfo.innerText = `File: ${file.name}`;

        try {
            let text = "";
            if (file.name.endsWith('.docx')) text = await parseDocx(file);
            else if (file.name.endsWith('.txt')) text = await parseTxt(file);
            else throw new Error("Chỉ hỗ trợ file Word (.docx) và Text (.txt)");

            inputArea.value = text;
            sessionStorage.setItem(CACHE_KEY, text);
            updateStats('input', text);

            // Sau khi load file xong, mở hộp thoại cấu hình luôn
            openConvertOption();
            Toast.fire({ icon: 'success', title: 'Đọc file thành công!' });

        } catch (err) {
            console.error(err);
            Swal.fire({ icon: 'error', title: 'Lỗi đọc file', text: err.message });
        } finally {
            loader.style.display = 'none';
        }
    }

    function parseDocx(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = function (event) {
                mammoth.extractRawText({ arrayBuffer: event.target.result })
                    .then(result => resolve(result.value)).catch(reject);
            };
            reader.onerror = reject;
            reader.readAsArrayBuffer(file);
        });
    }

    function parseTxt(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = e => resolve(e.target.result);
            reader.onerror = reject;
            reader.readAsText(file);
        });
    }

    // --- HỘP THOẠI CẤU HÌNH ---
    function openConvertOption() {
        const raw = document.getElementById('input').value;
        if (!raw.trim()) return Toast.fire({ icon: 'info', title: 'Chưa có dữ liệu!' });

        Swal.fire({
            title: 'Cấu hình chuẩn hóa',
            html: `
                <div style="text-align:left; font-size:14px;">
                    <label style="display:block; margin-bottom:10px; font-weight:600;">Số đáp án mỗi câu (để kiểm tra lỗi thiếu):</label>
                    <select id="swal-opt-count" style="width:100%; padding:8px; border-radius:6px; border:1px solid #ccc;">
                        <option value="4" selected>4 đáp án (A, B, C, D)</option>
                        <option value="3">3 đáp án (A, B, C)</option>
                        <option value="5">5 đáp án (A, B, C, D, E)</option>
                        <option value="0">Không kiểm tra (Tự do)</option>
                    </select>
                    <div style="margin-top:10px; font-size:12px; color:#666;">
                        <i>Hệ thống sẽ tự động thêm nhãn (VD: "A.") nếu phát hiện thiếu, dựa trên các đáp án còn lại.</i>
                    </div>
                </div>
            `,
            showCancelButton: true,
            confirmButtonText: 'Tiến hành chuẩn hóa',
            cancelButtonText: 'Hủy',
            confirmButtonColor: '#4f46e5',
        }).then((result) => {
            if (result.isConfirmed) {
                const optCount = parseInt(document.getElementById('swal-opt-count').value);
                convertData(true, optCount);
            }
        });
    }

    // --- LOGIC CHUẨN HÓA & SỬA LỖI ---
    function convertData(showToast = true, expectedOpts = 4) {
        const raw = document.getElementById('input').value;
        const outputEl = document.getElementById('output');

        const lines = raw.split(/\r?\n/);
        let qIndex = 1;
        let processedLines = [];
        let currentOptions = []; // Theo dõi các đáp án của câu hiện tại

        // Helper để xử lý câu trước đó khi gặp câu mới hoặc hết file
        const flushPreviousQuestion = () => {
            if (currentOptions.length > 0 && expectedOpts > 0) {
                // Logic kiểm tra và fix lỗi thiếu đáp án
                fixMissingLabels(processedLines, currentOptions, expectedOpts);
            }
            currentOptions = [];
        };

        for (let i = 0; i < lines.length; i++) {
            let text = lines[i].trim();
            if (!text) continue;

            // 1. NHẬN DIỆN CÂU HỎI
            const qMatch = text.match(/^(?:c[âa]u\s*)?\d+[\.\:\)\s]\s*(.*)/i);

            if (qMatch) {
                flushPreviousQuestion(); // Kết thúc câu cũ
                let content = qMatch[1] ? qMatch[1].trim() : "";
                processedLines.push(`Câu ${qIndex++}: ${content}`);
                continue;
            }

            // 2. NHẬN DIỆN ĐÁP ÁN (Có nhãn A, B, C...)
            const oMatch = text.match(/^(\*)?\s*([a-zA-Z])[\.\)]\s*(.*)/);
            if (oMatch) {
                const label = oMatch[2].toUpperCase();
                const isCorrect = !!oMatch[1];
                const content = oMatch[3].trim();

                processedLines.push(`${isCorrect ? '*' : ''}${label}. ${content}`);
                currentOptions.push({ label: label, lineIndex: processedLines.length - 1 });
                continue;
            }

            // 3. DÒNG KHÔNG CÓ NHÃN (Có thể là nội dung câu hỏi nối tiếp hoặc đáp án bị mất nhãn A, B..)
            // Logic đơn giản: Nếu dòng này ngắn và nằm sau các đáp án, có thể là đáp án thiếu
            // Tuy nhiên để an toàn, ta coi nó là text nối tiếp của dòng trước đó
            // Hoặc nếu người dùng muốn fix lỗi "thiếu A", ta sẽ xử lý ở bước flush
            processedLines.push(text);
        }

        flushPreviousQuestion(); // Xử lý câu cuối

        const result = processedLines.join('\n\n');
        outputEl.value = result;
        updateStats('output', result);

        if (showToast) Toast.fire({ icon: 'success', title: 'Đã chuẩn hóa và sửa lỗi!' });
    }

    // Hàm thông minh để tự điền đáp án thiếu
    function fixMissingLabels(allLines, opts, maxExpect) {
        if (opts.length === 0) return;

        // Map các label đã có
        const foundLabels = opts.map(o => o.label); // VD: ['B', 'C', 'D']
        const standardLabels = ['A', 'B', 'C', 'D', 'E', 'F'].slice(0, maxExpect);

        // Kiểm tra xem có thiếu label nào ở đầu không (VD thiếu A)
        // Nếu bắt đầu bằng B, mà trước dòng B đó có 1 dòng văn bản trôi nổi -> Gán A cho dòng đó
        if (foundLabels[0] !== 'A') {
            const firstOptIndex = opts[0].lineIndex;
            // Kiểm tra dòng ngay trên dòng đáp án đầu tiên
            const prevLineIndex = firstOptIndex - 1;

            if (prevLineIndex >= 0) {
                const prevLine = allLines[prevLineIndex];
                // Nếu dòng trên là "Câu X: ..." thì tức là thực sự thiếu đáp án A (mất hẳn) -> Thêm dòng mới
                if (prevLine.startsWith('Câu ')) {
                    // Chèn A. [Thiếu] vào giữa
                    allLines.splice(firstOptIndex, 0, "A. [Nội dung thiếu hoặc sai định dạng]");
                    // Cập nhật lại chỉ số (không cần thiết lắm vì ta chỉ push string)
                } else {
                    // Nếu dòng trên không phải Câu X, khả năng cao nó chính là đáp án A bị mất nhãn "A."
                    // VD: "Hà Nội" (dòng trên) -> "B. Đà Nẵng" (dòng dưới)
                    allLines[prevLineIndex] = `A. ${prevLine}`;
                }
            }
        }
    }

    function copyToClipboard() {
        const out = document.getElementById('output');
        if (!out.value.trim()) return Toast.fire({ icon: 'warning', title: 'Không có nội dung!' });
        out.select(); document.execCommand('copy');
        Toast.fire({ icon: 'success', title: 'Đã sao chép!' });
    }

    function transferToQuiz() {
        const val = document.getElementById('output').value;
        if (!val.trim()) return Swal.fire({ icon: 'error', title: 'Lỗi', text: 'Chưa có dữ liệu chuẩn hóa!', confirmButtonColor: '#d33' });

        localStorage.setItem('autoImportQuiz', val);

        Swal.fire({
            title: 'Đang chuyển hướng...', html: 'Vui lòng chờ trong giây lát.',
            timer: 800, timerProgressBar: true, didOpen: () => Swal.showLoading(),
            willClose: () => window.location.href = 'Default.aspx'
        });
    }
</script>
</asp:Content>