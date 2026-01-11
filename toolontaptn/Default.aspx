<%@ Page Title="Thi Trắc Nghiệm" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="toolontaptn.Default" ClientIDMode="Static" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* --- CORE LAYOUT --- */
        #quiz-wrapper { height: calc(100vh - 85px); display: flex; flex-direction: column; overflow: hidden; position: relative; }

        /* --- SETUP SCREEN --- */
        .setup-container { display: flex; gap: 20px; height: 100%; animation: fadeIn 0.4s ease; }
        .setup-card { background: var(--bg-nav); border: 1px solid var(--border-color); border-radius: 16px; padding: 20px; box-shadow: var(--shadow); display: flex; flex-direction: column; backdrop-filter: blur(10px); }
        .setup-left { flex: 7; display: flex; flex-direction: column; overflow: hidden; }
        .setup-right { flex: 3; gap: 15px; overflow-y: auto; }

        .tab-header { display: flex; gap: 10px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px; margin-bottom: 10px; justify-content: space-between; align-items: center; }
        .tab-controls { display: flex; gap: 10px; }
        .tab-btn { background: transparent; border: none; padding: 8px 16px; font-weight: 700; color: var(--text-muted); cursor: pointer; border-radius: 8px; transition: 0.2s; font-size: 13px; display: flex; align-items: center; gap: 6px; }
        .tab-btn:hover { background: rgba(0,0,0,0.05); color: var(--primary); }
        .tab-btn.active { background: var(--primary-glow); color: var(--primary); }
        .question-count-badge { font-size: 12px; color: var(--primary); font-weight: 700; background: var(--primary-glow); padding: 4px 10px; border-radius: 20px; }

        .tab-content { display: none; flex: 1; flex-direction: column; height: 100%; overflow: hidden; }
        .tab-content.active { display: flex; }

        textarea.pro-input { width: 100%; flex: 1; background: var(--bg-body); border: 2px solid var(--border-color); border-radius: 12px; padding: 15px; font-family: 'Consolas', monospace; font-size: 14px; color: var(--text-main); resize: none; outline: none; box-sizing: border-box; }
        textarea.pro-input:focus { border-color: var(--primary); }
        
        .guide-box { overflow-y: auto; font-size: 14px; line-height: 1.6; color: var(--text-main); padding-right: 5px; }
        .code-block { background: var(--bg-body); padding: 12px; border-radius: 8px; border: 1px dashed var(--border-color); font-family: monospace; margin: 10px 0; white-space: pre-wrap; color: var(--primary); font-size: 13px; }

        .mode-option { padding: 12px; border: 2px solid var(--border-color); border-radius: 12px; cursor: pointer; transition: 0.2s; background: var(--bg-body); display: flex; align-items: center; gap: 10px; margin-bottom: 10px; }
        .mode-option.active { border-color: var(--primary); background: var(--primary-glow); }
        .mode-icon { width: 36px; height: 36px; background: var(--bg-nav); border-radius: 8px; display: flex; align-items: center; justify-content: center; color: var(--primary); font-size: 18px; }

        .config-group { padding: 15px; background: var(--bg-body); border-radius: 12px; font-size: 13px; color: var(--text-main); display: flex; flex-direction: column; gap: 10px; border: 1px solid var(--border-color); }
        .config-row { display: flex; justify-content: space-between; align-items: center; }
        .config-input-small { width: 60px; padding: 6px; border: 1px solid var(--border-color); border-radius: 6px; text-align: center; font-weight: bold; outline: none; }
        .config-input-small:focus { border-color: var(--primary); }

        .btn-hero { background: var(--primary); color: white; border: none; padding: 15px; border-radius: 12px; font-weight: 800; cursor: pointer; width: 100%; font-size: 15px; margin-top: auto; transition: 0.2s; box-shadow: 0 4px 10px rgba(79, 70, 229, 0.2); }
        .btn-hero:hover { transform: translateY(-2px); opacity: 0.9; }

        /* --- QUIZ UI --- */
        #quiz-app { display: none; height: 100%; flex-direction: column; animation: slideUp 0.4s ease; }
        .quiz-header { height: 50px; display: flex; align-items: center; justify-content: space-between; padding: 0 10px; background: var(--bg-nav); border-bottom: 1px solid var(--border-color); border-radius: 16px 16px 0 0; flex-shrink: 0; }
        
        .progress-bar { height: 3px; background: var(--border-color); width: 100%; position: absolute; top: 0; left: 0; z-index: 10; }
        .progress-fill { height: 100%; background: var(--primary); width: 0%; transition: width 0.3s ease; }

        .quiz-body { display: flex; flex: 1; overflow: hidden; position: relative; background: var(--bg-body); }
        .q-area { flex: 1; overflow-y: auto; padding: 20px; scroll-behavior: smooth; }
        
        .q-card { background: var(--bg-nav); border-radius: 16px; padding: 25px; max-width: 800px; margin: 0 auto 80px auto; box-shadow: var(--shadow); border: 1px solid var(--border-color); }
        .q-meta { font-size: 12px; text-transform: uppercase; color: var(--primary); font-weight: 700; margin-bottom: 10px; letter-spacing: 0.5px; }
        .q-text { font-size: 17px; font-weight: 600; line-height: 1.5; margin-bottom: 20px; color: var(--text-main); }

        .option-item { display: flex; padding: 14px; margin-bottom: 8px; border-radius: 10px; border: 2px solid var(--border-color); cursor: pointer; background: var(--bg-body); transition: 0.1s; align-items: flex-start; }
        .option-marker { width: 24px; height: 24px; display: flex; align-items: center; justify-content: center; border: 2px solid var(--text-muted); margin-right: 12px; border-radius: 6px; font-weight: 700; color: var(--text-muted); flex-shrink: 0; font-size: 11px; margin-top: 1px; }
        .is-radio .option-marker { border-radius: 50%; }

        /* Result States */
        .selected { border-color: var(--primary); background: var(--primary-glow); }
        .selected .option-marker { background: var(--primary); border-color: var(--primary); color: white; }
        .correct { border-color: #10b981 !important; background: rgba(16, 185, 129, 0.1) !important; }
        .correct .option-marker { background: #10b981; border-color: #10b981; color: white; border: none; }
        .wrong { border-color: #ef4444 !important; background: rgba(239, 68, 68, 0.1) !important; }

        /* --- SIDEBAR --- */
        .sidebar { width: 300px; background: var(--bg-nav); border-left: 1px solid var(--border-color); display: flex; flex-direction: column; z-index: 900; transition: transform 0.3s ease; }
        .palette-grid { padding: 15px; display: grid; grid-template-columns: repeat(5, 1fr); gap: 8px; overflow-y: auto; flex: 1; align-content: start; }
        .p-item { aspect-ratio: 1; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: 13px; cursor: pointer; border: 1px solid var(--border-color); background: var(--bg-body); color: var(--text-muted); font-weight: 600; }
        .p-item:hover { border-color: var(--primary); color: var(--primary); }
        .p-item.current { border: 2px solid var(--primary); color: var(--primary); }
        .p-item.answered { background: var(--primary-glow); color: var(--primary); border-color: transparent; }
        .p-item.res-correct { background: #10b981; color: white; border: none; }
        .p-item.res-wrong { background: #ef4444; color: white; border: none; }

        .menu-toggle { display: none; font-size: 18px; color: var(--text-main); background: none; border: none; cursor: pointer; padding: 5px; }
        .sidebar-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.5); z-index: 899; opacity: 0; pointer-events: none; transition: opacity 0.3s; }
        
        .fab-nav { position: fixed; bottom: 30px; left: 50%; transform: translateX(-50%); display: flex; gap: 20px; z-index: 100; }
        .btn-circle { width: 48px; height: 48px; border-radius: 50%; border: 1px solid var(--border-color); background: var(--bg-nav); box-shadow: var(--shadow); color: var(--text-main); font-size: 18px; cursor: pointer; display: flex; align-items: center; justify-content: center; backdrop-filter: blur(5px); }
        .btn-circle:hover { background: var(--primary); color: white; border-color: var(--primary); }

        /* Button Check for Multi-Choice */
        .btn-check-answer { margin-top: 15px; width: 100%; padding: 10px; background: var(--bg-body); border: 2px solid var(--primary); color: var(--primary); font-weight: 700; border-radius: 10px; cursor: pointer; transition: 0.2s; }
        .btn-check-answer:hover { background: var(--primary); color: white; }

        @media (max-width: 900px) {
            .setup-container { flex-direction: column; gap: 10px; }
            .setup-left { flex: none; height: 55vh; }
            .setup-right { flex: 1; }
            .sidebar { position: fixed; top: 0; right: 0; bottom: 0; transform: translateX(100%); width: 280px; box-shadow: -5px 0 15px rgba(0,0,0,0.1); }
            .sidebar.open { transform: translateX(0); }
            .sidebar.open + .sidebar-overlay { opacity: 1; pointer-events: auto; }
            .menu-toggle { display: block; } 
            .quiz-header { padding: 0 15px; }
        }
        @media (min-width: 901px) {
            .sidebar { position: static; transform: none !important; }
            .sidebar-overlay { display: none; }
        }

        #result-modal.hidden { display: none; }
        #result-modal { position: fixed; inset: 0; background: rgba(0,0,0,0.7); backdrop-filter: blur(5px); z-index: 2000; display: flex; align-items: center; justify-content: center; animation: fadeIn 0.2s; }
        .modal-content { background: var(--bg-nav); width: 90%; max-width: 350px; padding: 30px; border-radius: 20px; text-align: center; border: 1px solid var(--border-color); box-shadow: 0 20px 50px rgba(0,0,0,0.3); }

        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
        @keyframes slideUp { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/canvas-confetti@1.6.0/dist/confetti.browser.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="quiz-wrapper">
        <div id="setup-screen" class="setup-container">
            <div class="setup-card setup-left">
                <div class="tab-header">
                    <div class="tab-controls">
                        <button type="button" class="tab-btn active" onclick="switchTab('input')"><i class="fa-solid fa-keyboard"></i> Nhập Đề</button>
                        <button type="button" class="tab-btn" onclick="switchTab('guide')"><i class="fa-solid fa-circle-info"></i> Hướng Dẫn</button>
                    </div>
                    <div class="question-count-badge" id="detected-count">Đã tìm thấy: 0 câu</div>
                </div>

                <div id="tab-input" class="tab-content active">
                    <textarea id="input-data" class="pro-input" placeholder="Dán nội dung câu hỏi vào đây..."></textarea>
                </div>

                <div id="tab-guide" class="tab-content">
                    <div class="guide-box">
                        <p><strong>1. Quy tắc nhập liệu:</strong></p>
                        <ul style="padding-left: 20px; margin: 0;">
                            <li>Câu hỏi bắt đầu bằng số thứ tự (1. hoặc Câu 1)</li>
                            <li>Đáp án bắt đầu bằng ký tự (A. hoặc A))</li>
                            <li><strong>Đáp án đúng:</strong> Thêm dấu * trước ký tự (VD: *A. Đúng)</li>
                            <li><strong>Câu nhiều đáp án:</strong> Đánh dấu * ở tất cả các đáp án đúng.</li>
                        </ul>
                        <p><strong>2. Mẫu ví dụ (Nhiều đáp án):</strong></p>
                        <div class="code-block">
1. Những thành phố nào trực thuộc TW?
*A. Hà Nội
B. Nha Trang
*C. TP.HCM
D. Đà Lạt
                        </div>
                        <button type="button" class="btn-hero" style="background:#10b981; padding:10px; font-size:13px;" onclick="copySample()">
                            <i class="fa-regular fa-copy"></i> Dùng thử mẫu này ngay
                        </button>
                    </div>
                </div>
            </div>
            
            <div class="setup-card setup-right">
                <h3 style="margin:0 0 10px 0; font-size:16px; color:var(--text-main);">Cấu Hình</h3>
                <div class="mode-option active" id="mode-practice" onclick="setMode('practice')">
                    <div class="mode-icon"><i class="fa-solid fa-book-open"></i></div>
                    <div style="flex:1">
                        <div style="font-weight: 700; color: var(--text-main); font-size:14px;">Ôn Tập</div>
                        <div style="font-size: 11px; color: var(--text-muted)">Sai hiện đỏ ngay</div>
                    </div>
                    <i class="fa-solid fa-circle-check" style="color:var(--primary)" id="chk-pra"></i>
                </div>
                <div class="mode-option" id="mode-exam" onclick="setMode('exam')">
                    <div class="mode-icon"><i class="fa-solid fa-stopwatch"></i></div>
                    <div style="flex:1">
                        <div style="font-weight: 700; color: var(--text-main); font-size:14px;">Thi Thử</div>
                        <div style="font-size: 11px; color: var(--text-muted)">Ẩn KQ, tính giờ</div>
                    </div>
                    <i class="fa-regular fa-circle" style="color:var(--text-muted)" id="chk-exa"></i>
                </div>
                <div class="config-group">
                      <div class="config-row">
                          <span style="font-weight:600"><i class="fa-solid fa-layer-group"></i> Số lượng câu</span>
                          <input type="number" id="cfg-limit" placeholder="All" min="1" class="config-input-small">
                      </div>
                      <div class="config-row">
                          <span style="font-weight:600"><i class="fa-solid fa-clock"></i> Thời gian (phút)</span>
                          <input type="number" id="cfg-time" value="45" class="config-input-small" disabled>
                      </div>
                      <label style="display:flex; gap:8px; align-items:center; margin-top:5px; cursor:pointer">
                          <input type="checkbox" id="cfg-shuffle-q"> <span style="font-weight:500">Tráo câu hỏi</span>
                      </label>
                      <label style="display:flex; gap:8px; align-items:center; cursor:pointer">
                          <input type="checkbox" id="cfg-shuffle-a"> <span style="font-weight:500">Tráo đáp án</span>
                      </label>
                </div>
                <button type="button" class="btn-hero" onclick="startQuiz()">BẮT ĐẦU <i class="fa-solid fa-arrow-right"></i></button>
            </div>
        </div>

        <div id="quiz-app">
            <div class="progress-bar"><div class="progress-fill" id="progress-line"></div></div>
            <div class="quiz-header">
                <div style="font-weight: 800; color: var(--primary); display: flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-list-ol"></i> <span id="q-counter">1/1</span>
                </div>
                <div style="display:flex; align-items:center; gap:15px;">
                    <div id="timer" class="hidden" style="color:#ef4444; font-weight:700; font-family:monospace;">00:00</div>
                    <button type="button" class="menu-toggle" onclick="toggleSidebar()"><i class="fa-solid fa-bars"></i></button>
                    <button type="button" onclick="backToSetup()" style="border:none; background:none; color:var(--text-muted); cursor:pointer; font-weight:600; font-size:13px;">Thoát</button>
                </div>
            </div>
            <div class="quiz-body">
                <div class="q-area" onclick="closeSidebar()">
                    <div id="main-container"></div>
                    <div style="height: 80px;"></div> </div>
                <div class="sidebar" id="sidebar">
                    <div style="padding:15px; font-weight:700; border-bottom:1px solid var(--border-color); color:var(--text-main); display:flex; justify-content:space-between;">
                        <span>Danh sách câu</span>
                        <i class="fa-solid fa-xmark menu-toggle" onclick="toggleSidebar()"></i>
                    </div>
                    <div class="palette-grid" id="palette"></div>
                    <div style="padding:15px; border-top:1px solid var(--border-color);">
                        <button type="button" id="btn-submit-sidebar" class="btn-hero" style="padding:12px;" onclick="confirmSubmit()">NỘP BÀI</button>
                    </div>
                </div>
                <div class="sidebar-overlay" onclick="toggleSidebar()"></div>
            </div>
            <div class="fab-nav" id="nav-btns">
                <button type="button" class="btn-circle" onclick="changeSlide(-1)"><i class="fa-solid fa-chevron-left"></i></button>
                <button type="button" class="btn-circle" onclick="changeSlide(1)"><i class="fa-solid fa-chevron-right"></i></button>
            </div>
        </div>

        <div id="result-modal" class="hidden">
            <div class="modal-content">
                <h2 style="margin:0 0 10px 0; color:var(--text-main);">Kết Quả</h2>
                <div id="res-score" style="font-size:48px; font-weight:900; color:var(--primary); line-height:1;">0 điểm</div>
                <p id="res-msg" style="color:var(--text-muted); font-size:14px; margin-bottom:20px;">Làm tốt lắm!</p>
                <button type="button" class="btn-hero" onclick="restartQuiz()">Làm lại bài</button>
                <button type="button" onclick="reviewQuiz()" style="width:100%; margin-top:10px; padding:12px; background:none; border:1px solid var(--border-color); color:var(--text-main); border-radius:10px; cursor:pointer; font-weight:600;">Xem đáp án</button>
            </div>
        </div>
    </div>

<script>
    const CACHE_KEY = 'quiz_draft_data';
    const IMPORT_KEY = 'autoImportQuiz';
    const Toast = Swal.mixin({ toast: true, position: 'top-end', showConfirmButton: false, timer: 3000, timerProgressBar: true });

    // Thêm mảng checkedQuestions để theo dõi các câu đã bấm "Kiểm tra" trong chế độ Ôn tập
    let app = { mode: 'practice', questions: [], currentIndex: 0, userAnswers: [], checkedQuestions: [], timerId: null, timeRemaining: 0, isSubmitted: false };

    document.addEventListener('DOMContentLoaded', () => {
        const inputArea = document.getElementById('input-data');
        const countBadge = document.getElementById('detected-count');

        const updateCount = () => {
            const regex = /^(?:c[âa]u\s*)?\d+[\.\:\)\s]\s*\S+/gim;
            const count = (inputArea.value.match(regex) || []).length;
            countBadge.innerText = `Đã tìm thấy: ${count} câu`;
            const limitInput = document.getElementById('cfg-limit');
            if (limitInput) limitInput.setAttribute('max', count);
        };

        const imported = localStorage.getItem(IMPORT_KEY);
        if (imported) {
            inputArea.value = imported;
            sessionStorage.setItem(CACHE_KEY, imported);
            localStorage.removeItem(IMPORT_KEY);
            switchTab('input');
            setTimeout(updateCount, 50);
            Toast.fire({ icon: 'success', title: 'Đã nhận dữ liệu từ Tool!' });
        } else {
            const cached = sessionStorage.getItem(CACHE_KEY);
            if (cached) { inputArea.value = cached; updateCount(); }
        }
        inputArea.addEventListener('input', function () { sessionStorage.setItem(CACHE_KEY, this.value); updateCount(); });
        updateCount();
    });

    function switchTab(name) {
        document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
        document.getElementById(`tab-${name}`).classList.add('active');
        document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
        event.currentTarget.classList.add('active');
    }

    function copySample() {
        const sample = "1. Những thành phố nào trực thuộc TW?\n*A. Hà Nội\nB. Nha Trang\n*C. TP.HCM\nD. Đà Lạt\n\n2. 2 + 2 bằng mấy?\n*A. 4\nB. 5\nC. 6";
        const inputArea = document.getElementById('input-data');
        inputArea.value = sample;
        inputArea.dispatchEvent(new Event('input'));
        switchTab('input');
        Toast.fire({ icon: 'info', title: 'Đã nạp mẫu thử nghiệm (Câu nhiều đáp án)' });
    }

    function toggleSidebar() { document.getElementById('sidebar').classList.toggle('open'); }
    function closeSidebar() { document.getElementById('sidebar').classList.remove('open'); }
    function backToSetup() {
        Swal.fire({
            title: 'Thoát bài thi?', text: "Tiến độ hiện tại sẽ mất.", icon: 'warning', showCancelButton: true, confirmButtonColor: '#ef4444', cancelButtonColor: '#64748b', confirmButtonText: 'Thoát', cancelButtonText: 'Ở lại'
        }).then((r) => { if (r.isConfirmed) location.reload(); });
    }

    function setMode(mode) {
        app.mode = mode;
        document.getElementById('mode-practice').classList.toggle('active', mode === 'practice');
        document.getElementById('mode-exam').classList.toggle('active', mode === 'exam');
        document.getElementById('chk-pra').className = mode === 'practice' ? 'fa-solid fa-circle-check' : 'fa-regular fa-circle';
        document.getElementById('chk-exa').className = mode === 'exam' ? 'fa-solid fa-circle-check' : 'fa-regular fa-circle';
        const tm = document.getElementById('cfg-time');
        tm.disabled = (mode === 'practice');
        tm.style.opacity = mode === 'practice' ? '0.5' : '1';
    }

    function parseInput(text) {
        const lines = text.split('\n');
        let qs = [], currentQ = null;
        const optionRegex = /^(\*)?\s*([a-zA-Z])[\.\)]\s+(.*)/;

        lines.forEach(line => {
            line = line.trim();
            if (!line) return;
            const match = line.match(optionRegex);
            if (match) {
                if (currentQ) currentQ.options.push({ label: match[2].toUpperCase(), content: match[3], isCorrect: match[1] === '*' });
            } else {
                const prefixMatch = line.match(/^(?:c[âa]u\s*)?\d+[\.\:\)\s]\s*/i);
                if (prefixMatch) {
                    if (currentQ && currentQ.options.length > 0) qs.push(currentQ);
                    let cleanText = line.substring(prefixMatch[0].length).trim();
                    currentQ = { text: cleanText, options: [], type: 'single' };
                } else {
                    if (currentQ) currentQ.text += "<br/>" + line;
                }
            }
        });
        if (currentQ && currentQ.options.length > 0) qs.push(currentQ);

        return qs.map(q => {
            q.type = q.options.filter(o => o.isCorrect).length > 1 ? 'multi' : 'single';
            return q;
        });
    }

    function startQuiz() {
        const raw = document.getElementById('input-data').value;
        let qs = parseInput(raw);
        if (!qs.length) { Swal.fire({ icon: 'error', title: 'Dữ liệu trống', text: 'Vui lòng nhập câu hỏi!', confirmButtonColor: '#4f46e5' }); return; }

        const totalQ = qs.length;
        let limit = parseInt(document.getElementById('cfg-limit').value);
        if (isNaN(limit) || limit <= 0) limit = totalQ;
        if (limit > totalQ) { Swal.fire({ icon: 'warning', title: 'Số lượng không hợp lệ', text: `Chỉ có tối đa ${totalQ} câu hỏi.`, confirmButtonColor: '#f59e0b' }); return; }

        const shuffleQ = document.getElementById('cfg-shuffle-q').checked;
        if (limit < totalQ) { qs.sort(() => Math.random() - 0.5); qs = qs.slice(0, limit); }
        else if (shuffleQ) { qs.sort(() => Math.random() - 0.5); }

        if (document.getElementById('cfg-shuffle-a').checked) {
            qs.forEach(q => {
                q.options.sort(() => Math.random() - 0.5);
                q.options.forEach((o, i) => o.label = String.fromCharCode(65 + i));
            });
        }

        app.questions = qs;
        app.userAnswers = qs.map(() => []);
        app.checkedQuestions = []; // Reset trạng thái check câu hỏi
        app.isSubmitted = false;
        app.currentIndex = 0;

        // Reset nút Nộp bài về trạng thái ban đầu
        const submitBtn = document.getElementById('btn-submit-sidebar');
        submitBtn.innerText = "NỘP BÀI";
        submitBtn.setAttribute('onclick', 'confirmSubmit()');

        document.getElementById('setup-screen').style.display = 'none';
        document.getElementById('quiz-app').style.display = 'flex';

        if (app.mode === 'exam') {
            app.timeRemaining = (parseInt(document.getElementById('cfg-time').value) || 45) * 60;
            startTimer();
            document.getElementById('timer').classList.remove('hidden');
            document.getElementById('nav-btns').style.display = 'none';
            renderAllQuestions();
        } else {
            document.getElementById('timer').classList.add('hidden');
            document.getElementById('nav-btns').style.display = 'flex';
            renderOneQuestion(0);
        }
        renderPalette();
        updateProgress();
    }

    function getQuestionHTML(q, idx) {
        const u = app.userAnswers[idx];
        const isMultiPractice = app.mode === 'practice' && q.type === 'multi';
        const isChecked = app.checkedQuestions.includes(idx);

        // Logic hiển thị màu: Đã nộp bài HOẶC (thực hành đơn && đã chọn) HOẶC (thực hành đa && đã bấm kiểm tra)
        const showRes = app.isSubmitted || (app.mode === 'practice' && q.type === 'single' && u.length > 0) || (isMultiPractice && isChecked);

        const cardClass = q.type === 'single' ? 'q-card is-single' : 'q-card';
        const typeLabel = q.type === 'multi' ? '<span style="color:#f97316; font-size:11px; margin-left:5px;">(CHỌN NHIỀU)</span>' : '';

        let h = `<div class="${cardClass}" id="q-card-${idx}">
            <div class="q-meta">CÂU ${idx + 1} ${typeLabel}</div>
            <div class="q-text">${q.text}</div><div>`;

        q.options.forEach((o, i) => {
            let cls = 'option-item';
            const sel = u.includes(i);

            if (showRes) {
                if (o.isCorrect) cls += ' correct';
                else if (sel) cls += ' wrong';
                // Đánh dấu sai nếu thiếu đáp án đúng (cho câu nhiều lựa chọn)
                if (q.type === 'multi' && o.isCorrect && !sel) cls += ' wrong';
            } else if (sel) {
                cls += ' selected';
            }

            h += `<div class="${cls}" onclick="handleSelect(${idx}, ${i})">
                    <div class="option-marker">${o.label}</div>
                    <div style="flex:1">${o.content}</div>
                  </div>`;
        });

        // Thêm nút Kiểm tra cho câu hỏi nhiều đáp án ở chế độ Ôn tập
        if (isMultiPractice && !isChecked && !app.isSubmitted) {
            h += `<button class="btn-check-answer" onclick="checkQuestion(${idx})">Kiểm tra</button>`;
        }

        return h + '</div></div>';
    }

    function renderOneQuestion(i) {
        if (i < 0 || i >= app.questions.length) return;
        app.currentIndex = i;
        document.getElementById('main-container').innerHTML = getQuestionHTML(app.questions[i], i);
        document.getElementById('q-counter').innerText = `${i + 1}/${app.questions.length}`;
        renderPalette();
        updateProgress();
    }

    function renderAllQuestions() {
        document.getElementById('main-container').innerHTML = app.questions.map((q, i) => getQuestionHTML(q, i)).join('');
        updateProgress();
    }

    function handleSelect(qIdx, oIdx) {
        if (app.isSubmitted) return;
        const q = app.questions[qIdx];

        // Nếu là câu đơn trong chế độ ôn tập và đã chọn rồi -> không cho chọn lại (trừ khi làm lại bài)
        if (app.mode === 'practice' && q.type === 'single' && app.userAnswers[qIdx].length > 0) return;

        // Nếu là câu nhiều đáp án trong chế độ ôn tập và đã bấm kiểm tra -> không cho sửa nữa
        if (app.mode === 'practice' && q.type === 'multi' && app.checkedQuestions.includes(qIdx)) return;

        let cur = app.userAnswers[qIdx];
        if (q.type === 'single') {
            app.userAnswers[qIdx] = [oIdx];
        } else {
            const f = cur.indexOf(oIdx);
            f === -1 ? cur.push(oIdx) : cur.splice(f, 1);
        }

        if (app.mode === 'exam') {
            const el = document.getElementById(`q-card-${qIdx}`);
            if (el) el.outerHTML = getQuestionHTML(q, qIdx);
        } else {
            renderOneQuestion(qIdx);
        }
        renderPalette();
        updateProgress();
    }

    // Hàm xử lý khi bấm nút "Kiểm tra" ở câu nhiều đáp án
    function checkQuestion(idx) {
        if (!app.checkedQuestions.includes(idx)) {
            app.checkedQuestions.push(idx);
            renderOneQuestion(idx);
        }
    }

    function renderPalette() {
        const p = document.getElementById('palette'); p.innerHTML = '';
        app.questions.forEach((q, i) => {
            const d = document.createElement('div');
            d.className = 'p-item'; d.innerText = i + 1;
            const u = app.userAnswers[i];

            // Logic hiển thị màu sidebar
            const isMultiPractice = app.mode === 'practice' && q.type === 'multi';
            const isChecked = app.checkedQuestions.includes(i);
            const show = app.isSubmitted || (app.mode === 'practice' && q.type === 'single' && u.length > 0) || (isMultiPractice && isChecked);

            if (show) {
                const c = q.options.map((o, k) => o.isCorrect ? k : -1).filter(k => k !== -1);
                // Đúng khi chọn đủ và không thừa
                const isOk = u.length === c.length && u.every(v => c.includes(v));

                // Chỉ tô màu nếu đã có câu trả lời (hoặc đã nộp bài)
                if (u.length > 0 || app.isSubmitted) d.classList.add(isOk ? 'res-correct' : 'res-wrong');
            } else if (u.length > 0) d.classList.add('answered');

            if (i === app.currentIndex && app.mode !== 'exam') d.classList.add('current');
            d.onclick = () => {
                closeSidebar();
                if (app.mode === 'exam') document.getElementById(`q-card-${i}`).scrollIntoView({ behavior: 'smooth', block: 'center' });
                else renderOneQuestion(i);
            };
            p.appendChild(d);
        });
    }

    function updateProgress() {
        const pct = (app.userAnswers.filter(a => a.length > 0).length / app.questions.length) * 100;
        document.getElementById('progress-line').style.width = pct + '%';
    }
    function changeSlide(d) { renderOneQuestion(app.currentIndex + d); }

    function startTimer() {
        if (app.timerId) clearInterval(app.timerId);
        app.timerId = setInterval(() => {
            app.timeRemaining--;
            const m = Math.floor(app.timeRemaining / 60).toString().padStart(2, '0');
            const s = (app.timeRemaining % 60).toString().padStart(2, '0');
            document.getElementById('timer').innerText = m + ':' + s;
            if (app.timeRemaining <= 0) finishQuiz();
        }, 1000);
    }

    function confirmSubmit() {
        const unanswered = app.userAnswers.filter(a => a.length === 0).length;
        const msg = unanswered > 0 ? `Còn ${unanswered} câu chưa làm.` : 'Bạn đã làm hết các câu hỏi.';
        Swal.fire({
            title: 'Nộp bài?', text: `${msg} Bạn có chắc chắn muốn nộp không?`, icon: 'question', showCancelButton: true, confirmButtonColor: '#4f46e5', cancelButtonColor: '#64748b', confirmButtonText: 'Nộp ngay', cancelButtonText: 'Làm tiếp'
        }).then((r) => { if (r.isConfirmed) finishQuiz(); });
    }

    function finishQuiz() {
        if (app.isSubmitted) return;
        clearInterval(app.timerId);
        app.isSubmitted = true;
        let score = 0;
        app.questions.forEach((q, i) => {
            const u = app.userAnswers[i];
            const c = q.options.map((o, k) => o.isCorrect ? k : -1).filter(k => k !== -1);
            if (u.length === c.length && u.every(v => c.includes(v))) score++;
        });

        if (app.mode === 'exam') renderAllQuestions(); else renderOneQuestion(app.currentIndex);
        renderPalette();

        // Hiển thị điểm số dạng số nguyên "X điểm"
        document.getElementById('res-score').innerText = `${score} điểm`;
        document.getElementById('res-msg').innerText = `Bạn làm đúng ${score}/${app.questions.length} câu.`;

        document.getElementById('result-modal').classList.remove('hidden');
        if ((score / app.questions.length) >= 0.7) confetti({ particleCount: 150, spread: 70, origin: { y: 0.6 } });
    }

    function restartQuiz() { document.getElementById('result-modal').classList.add('hidden'); startQuiz(); }

    function reviewQuiz() {
        document.getElementById('result-modal').classList.add('hidden');
        // Đổi nút Nộp bài thành Làm lại bài
        const submitBtn = document.getElementById('btn-submit-sidebar');
        submitBtn.innerText = "LÀM LẠI BÀI";
        submitBtn.setAttribute('onclick', 'restartQuiz()');
        submitBtn.style.background = "#6366f1"; // Đổi màu chút cho khác biệt
    }
</script>
</asp:Content>