<%@ Page Title="Thi Trắc Nghiệm" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="toolontaptn.Default" ClientIDMode="Static" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* --- CORE LAYOUT --- */
        #quiz-wrapper { height: calc(100vh - 85px); display: flex; flex-direction: column; overflow: hidden; position: relative; }

        /* --- SETUP SCREEN (Tabs & Config) --- */
        .setup-container { display: flex; gap: 20px; height: 100%; animation: fadeIn 0.4s ease; }
        .setup-card { background: var(--bg-nav); border: 1px solid var(--border-color); border-radius: 16px; padding: 20px; box-shadow: var(--shadow); display: flex; flex-direction: column; backdrop-filter: blur(10px); }
        .setup-left { flex: 7; display: flex; flex-direction: column; overflow: hidden; }
        .setup-right { flex: 3; gap: 15px; overflow-y: auto; }

        /* Tabs */
        .tab-header { display: flex; gap: 10px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px; margin-bottom: 10px; }
        .tab-btn { background: transparent; border: none; padding: 8px 16px; font-weight: 700; color: var(--text-muted); cursor: pointer; border-radius: 8px; transition: 0.2s; font-size: 13px; display: flex; align-items: center; gap: 6px; }
        .tab-btn:hover { background: rgba(0,0,0,0.05); color: var(--primary); }
        .tab-btn.active { background: var(--primary-glow); color: var(--primary); }
        .tab-content { display: none; flex: 1; flex-direction: column; height: 100%; overflow: hidden; }
        .tab-content.active { display: flex; }

        /* Inputs & Guide */
        textarea.pro-input { width: 100%; flex: 1; background: var(--bg-body); border: 2px solid var(--border-color); border-radius: 12px; padding: 15px; font-family: 'Consolas', monospace; font-size: 14px; color: var(--text-main); resize: none; outline: none; box-sizing: border-box; }
        textarea.pro-input:focus { border-color: var(--primary); }
        
        .guide-box { overflow-y: auto; font-size: 14px; line-height: 1.6; color: var(--text-main); padding-right: 5px; }
        .code-block { background: var(--bg-body); padding: 12px; border-radius: 8px; border: 1px dashed var(--border-color); font-family: monospace; margin: 10px 0; white-space: pre-wrap; color: var(--primary); font-size: 13px; }

        /* Settings */
        .mode-option { padding: 12px; border: 2px solid var(--border-color); border-radius: 12px; cursor: pointer; transition: 0.2s; background: var(--bg-body); display: flex; align-items: center; gap: 10px; margin-bottom: 10px; }
        .mode-option.active { border-color: var(--primary); background: var(--primary-glow); }
        .mode-icon { width: 36px; height: 36px; background: var(--bg-nav); border-radius: 8px; display: flex; align-items: center; justify-content: center; color: var(--primary); font-size: 18px; }

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

        /* --- SIDEBAR / DRAWER --- */
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
        
        /* FAB Navigation */
        .fab-nav { position: fixed; bottom: 30px; left: 50%; transform: translateX(-50%); display: flex; gap: 20px; z-index: 100; }
        .btn-circle { width: 48px; height: 48px; border-radius: 50%; border: 1px solid var(--border-color); background: var(--bg-nav); box-shadow: var(--shadow); color: var(--text-main); font-size: 18px; cursor: pointer; display: flex; align-items: center; justify-content: center; backdrop-filter: blur(5px); }
        .btn-circle:hover { background: var(--primary); color: white; border-color: var(--primary); }

        /* --- RESPONSIVE LOGIC --- */
        @media (max-width: 900px) {
            .setup-container { flex-direction: column; gap: 10px; }
            .setup-left { flex: none; height: 55vh; }
            .setup-right { flex: 1; }
            
            /* Sidebar turns into Drawer */
            .sidebar { position: fixed; top: 0; right: 0; bottom: 0; transform: translateX(100%); width: 280px; box-shadow: -5px 0 15px rgba(0,0,0,0.1); }
            .sidebar.open { transform: translateX(0); }
            .sidebar.open + .sidebar-overlay { opacity: 1; pointer-events: auto; }
            
            .menu-toggle { display: block; } /* Show Hamburger */
            .quiz-header { padding: 0 15px; }
        }

        @media (min-width: 901px) {
            .sidebar { position: static; transform: none !important; }
            .sidebar-overlay { display: none; }
        }

        /* Result Modal */
        #result-modal.hidden { display: none; }
        #result-modal { position: fixed; inset: 0; background: rgba(0,0,0,0.7); backdrop-filter: blur(5px); z-index: 2000; display: flex; align-items: center; justify-content: center; animation: fadeIn 0.2s; }
        .modal-content { background: var(--bg-nav); width: 90%; max-width: 350px; padding: 30px; border-radius: 20px; text-align: center; border: 1px solid var(--border-color); box-shadow: 0 20px 50px rgba(0,0,0,0.3); }

        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
        @keyframes slideUp { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/canvas-confetti@1.6.0/dist/confetti.browser.min.js"></script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="quiz-wrapper">
        
        <div id="setup-screen" class="setup-container">
            <div class="setup-card setup-left">
                <div class="tab-header">
                    <button type="button" class="tab-btn active" onclick="switchTab('input')"><i class="fa-solid fa-keyboard"></i> Nhập Đề</button>
                    <button type="button" class="tab-btn" onclick="switchTab('guide')"><i class="fa-solid fa-circle-info"></i> Hướng Dẫn</button>
                </div>

                <div id="tab-input" class="tab-content active">
                    <textarea id="input-data" class="pro-input" placeholder="Dán nội dung câu hỏi vào đây..."></textarea>
                </div>

                <div id="tab-guide" class="tab-content">
                    <div class="guide-box">
                        <p><strong>1. Quy tắc nhập liệu:</strong></p>
                        <ul style="padding-left: 20px; margin: 0;">
                            <li>Câu hỏi bắt đầu bằng số thứ tự (1. hoặc 1 hoặc Câu 1: "cái này sao cũng được")</li>
                            <li>Đáp án bắt đầu bằng ký tự (a. hoặc A. hoặc a))</li>
                            <li><strong>Đáp án đúng:</strong> Thêm dấu * trước ký tự (VD: *A. Đúng)</li>
                        </ul>
                        <p><strong>2. Mẫu ví dụ:</strong></p>
                        <div class="code-block">1. đâu là thủ đô của VN?
A. Cần Thơ
*B. Hà Nội
C. TP.HCM</div>
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

                <div style="padding: 10px; background:var(--bg-body); border-radius:10px; font-size:13px; color:var(--text-main);">
                     <label style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
                         <span>⏱️ Thời gian (phút)</span>
                         <input type="number" id="cfg-time" value="45" style="width: 50px; padding: 4px; border: 1px solid var(--border-color); border-radius: 4px; text-align: center;" disabled>
                     </label>
                     <label style="display:flex; gap:8px; align-items:center; margin-bottom:5px; cursor:pointer">
                         <input type="checkbox" id="cfg-shuffle-q" checked> Tráo câu hỏi
                     </label>
                     <label style="display:flex; gap:8px; align-items:center; cursor:pointer">
                         <input type="checkbox" id="cfg-shuffle-a"> Tráo đáp án
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
                        <button type="button" class="btn-hero" style="padding:12px;" onclick="confirmSubmit()">NỘP BÀI</button>
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
                <div id="res-score" style="font-size:48px; font-weight:900; color:var(--primary); line-height:1;">0/0</div>
                <p id="res-msg" style="color:var(--text-muted); font-size:14px; margin-bottom:20px;">Làm tốt lắm!</p>
                <button type="button" class="btn-hero" onclick="restartQuiz()">Làm lại bài</button>
                <button type="button" onclick="reviewQuiz()" style="width:100%; margin-top:10px; padding:12px; background:none; border:1px solid var(--border-color); color:var(--text-main); border-radius:10px; cursor:pointer; font-weight:600;">Xem đáp án</button>
                <button type="button" onclick="backToSetup()" style="margin-top:15px; background:none; border:none; color:var(--text-muted); cursor:pointer; font-size:13px;">Về màn hình chính</button>
            </div>
        </div>
    </div>

<script>
    // --- 1. CONFIG & UTILS ---
    const CACHE_KEY = 'quiz_draft_data';   // Cache của phiên làm việc (mất khi đóng browser)
    const IMPORT_KEY = 'autoImportQuiz';   // Key nhận từ Tool

    // Mixin cho thông báo nhỏ (Toast)
    const Toast = Swal.mixin({
        toast: true,
        position: 'top-end',
        showConfirmButton: false,
        timer: 3000,
        timerProgressBar: true
    });

    let app = { 
        mode: 'practice', 
        questions: [], 
        currentIndex: 0, 
        userAnswers: [], 
        timerId: null, 
        timeRemaining: 0, 
        isSubmitted: false 
    };

    // --- 2. INIT & CACHE LOGIC ---
    document.addEventListener('DOMContentLoaded', () => {
        const inputArea = document.getElementById('input-data');

        // A. Kiểm tra dữ liệu chuyển từ Tool (Ưu tiên 1)
        const imported = localStorage.getItem(IMPORT_KEY);
        if (imported) {
            inputArea.value = imported;
            sessionStorage.setItem(CACHE_KEY, imported); // Lưu ngay vào cache phiên
            localStorage.removeItem(IMPORT_KEY);         // Xóa key chuyển để không load lại
            switchTab('input');
            Toast.fire({ icon: 'success', title: 'Đã nhận dữ liệu từ Tool!' });
        } 
        // B. Kiểm tra dữ liệu cũ trong phiên (Ưu tiên 2 - khi F5)
        else {
            const cached = sessionStorage.getItem(CACHE_KEY);
            if (cached) {
                inputArea.value = cached;
            }
        }

        // C. Lắng nghe nhập liệu để lưu Cache liên tục
        inputArea.addEventListener('input', function() {
            sessionStorage.setItem(CACHE_KEY, this.value);
        });
    });

    // --- 3. UI TABS & NAVIGATION ---
    function switchTab(name) {
        document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
        document.getElementById(`tab-${name}`).classList.add('active');
        document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
        event.currentTarget.classList.add('active');
    }

    function copySample() {
        const sample = "1. Thủ đô của Việt Nam là?\nA. TP. Hồ Chí Minh\n*B. Hà Nội\nC. Đà Nẵng\n\n2. 2 + 2 bằng mấy?\n*A. 4\nB. 5\nC. 6";
        const inputArea = document.getElementById('input-data');
        inputArea.value = sample;
        sessionStorage.setItem(CACHE_KEY, sample); // Lưu cache mẫu
        switchTab('input');
        Toast.fire({ icon: 'info', title: 'Đã nạp mẫu thử nghiệm' });
    }

    function toggleSidebar() { document.getElementById('sidebar').classList.toggle('open'); }
    function closeSidebar() { document.getElementById('sidebar').classList.remove('open'); }

    function backToSetup() { 
        Swal.fire({
            title: 'Thoát bài thi?',
            text: "Tiến độ làm bài hiện tại sẽ bị mất.",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Thoát',
            cancelButtonText: 'Ở lại'
        }).then((result) => {
            if (result.isConfirmed) {
                location.reload();
            }
        });
    }

    // --- 4. CORE QUIZ LOGIC ---
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
        // Regex nhận diện đáp án (hỗ trợ A. hoặc A) hoặc a.)
        const optionRegex = /^(\*)?([a-zA-Z])[\.\)]\s+(.*)/; 
        
        lines.forEach(line => {
            line = line.trim();
            if (!line) return;
            const match = line.match(optionRegex);
            if (match) {
                if (currentQ) {
                    currentQ.options.push({ 
                        label: match[2].toUpperCase(), 
                        content: match[3], 
                        isCorrect: match[1] === '*' 
                    });
                }
            } else {
                // Nhận diện câu hỏi mới
                if (!currentQ || currentQ.options.length > 0) {
                    currentQ = { text: line, options: [], type: 'single' }; 
                    qs.push(currentQ);
                } else {
                    // Nối thêm dòng vào câu hỏi nếu câu hỏi nhiều dòng
                    currentQ.text += "<br/>" + line;
                }
            }
        });
        // Lọc bỏ câu lỗi và xác định loại câu (single/multi)
        return qs.filter(q => q.options.length > 0).map(q => { 
            q.type = q.options.filter(o => o.isCorrect).length > 1 ? 'multi' : 'single'; 
            return q; 
        });
    }

    function startQuiz() {
        const raw = document.getElementById('input-data').value;
        let qs = parseInput(raw);
        
        if (!qs.length) {
            Swal.fire({
                icon: 'error',
                title: 'Dữ liệu trống',
                text: 'Vui lòng nhập hoặc dán câu hỏi vào khung nhập liệu!',
                confirmButtonColor: '#4f46e5'
            });
            return;
        }

        // Xử lý cấu hình tráo đổi
        if (document.getElementById('cfg-shuffle-q').checked) qs.sort(() => Math.random() - 0.5);
        if (document.getElementById('cfg-shuffle-a').checked) {
            qs.forEach(q => {
                q.options.sort(() => Math.random() - 0.5);
                // Đánh lại nhãn A, B, C... sau khi tráo
                q.options.forEach((o, i) => o.label = String.fromCharCode(65 + i));
            });
        }

        app.questions = qs;
        app.userAnswers = qs.map(() => []);
        app.isSubmitted = false;
        app.currentIndex = 0;

        // Chuyển màn hình
        document.getElementById('setup-screen').style.display = 'none';
        document.getElementById('quiz-app').style.display = 'flex';

        if (app.mode === 'exam') {
            app.timeRemaining = (parseInt(document.getElementById('cfg-time').value) || 45) * 60;
            startTimer();
            document.getElementById('timer').classList.remove('hidden');
            document.getElementById('nav-btns').style.display = 'none'; // Thi thử ẩn nút Next/Prev ở dưới
            renderAllQuestions(); // Thi thử hiện tất cả câu (dạng cuộn)
        } else {
            document.getElementById('timer').classList.add('hidden');
            document.getElementById('nav-btns').style.display = 'flex';
            renderOneQuestion(0);
        }
        renderPalette();
        updateProgress();
    }

    // --- 5. RENDER LOGIC ---
    function getQuestionHTML(q, idx) {
        const u = app.userAnswers[idx];
        const showRes = app.isSubmitted || (app.mode === 'practice' && u.length > 0);
        
        let h = `<div class="q-card" id="q-card-${idx}">
            <div class="q-meta">CÂU ${idx + 1} ${q.type === 'multi' ? '(CHỌN NHIỀU)' : ''}</div>
            <div class="q-text">${q.text}</div><div>`;
        
        q.options.forEach((o, i) => {
            let cls = 'option-item';
            const sel = u.includes(i);
            
            if (showRes) {
                if (o.isCorrect) cls += ' correct';
                else if (sel) cls += ' wrong';
            } else if (sel) {
                cls += ' selected';
            }

            h += `<div class="${cls}" onclick="handleSelect(${idx}, ${i})">
                    <div class="option-marker">${o.label}</div>
                    <div style="flex:1">${o.content}</div>
                  </div>`;
        });
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
        
        // Chế độ ôn tập: Nếu đã trả lời rồi thì không cho chọn lại (với câu hỏi 1 đáp án)
        if (app.mode === 'practice' && app.userAnswers[qIdx].length > 0 && q.type === 'single') return;

        let cur = app.userAnswers[qIdx];
        if (q.type === 'single') {
            app.userAnswers[qIdx] = [oIdx];
        } else {
            const f = cur.indexOf(oIdx);
            f === -1 ? cur.push(oIdx) : cur.splice(f, 1);
        }

        // Render lại giao diện câu hỏi
        if (app.mode === 'exam') {
            const el = document.getElementById(`q-card-${qIdx}`);
            if (el) el.outerHTML = getQuestionHTML(q, qIdx);
        } else {
            renderOneQuestion(qIdx);
        }

        renderPalette();
        updateProgress();
    }

    function renderPalette() {
        const p = document.getElementById('palette'); p.innerHTML = '';
        app.questions.forEach((q, i) => {
            const d = document.createElement('div'); 
            d.className = 'p-item'; 
            d.innerText = i + 1;
            
            const u = app.userAnswers[i];
            const show = app.isSubmitted || (app.mode === 'practice' && u.length > 0);

            if (show) {
                const c = q.options.map((o, k) => o.isCorrect ? k : -1).filter(k => k !== -1);
                const isOk = u.length === c.length && u.every(v => c.includes(v));
                if (u.length > 0) d.classList.add(isOk ? 'res-correct' : 'res-wrong');
            } else if (u.length > 0) {
                d.classList.add('answered');
            }

            if (i === app.currentIndex && app.mode !== 'exam') d.classList.add('current');
            
            d.onclick = () => { 
                closeSidebar(); 
                if (app.mode === 'exam') {
                    document.getElementById(`q-card-${i}`).scrollIntoView({ behavior: 'smooth', block: 'center' }); 
                } else {
                    renderOneQuestion(i); 
                }
            };
            p.appendChild(d);
        });
    }

    function updateProgress() {
        const pct = (app.userAnswers.filter(a => a.length > 0).length / app.questions.length) * 100;
        document.getElementById('progress-line').style.width = pct + '%';
    }

    function changeSlide(d) { renderOneQuestion(app.currentIndex + d); }

    // --- 6. TIMER & SUBMIT ---
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
            title: 'Nộp bài?',
            text: `${msg} Bạn có chắc chắn muốn nộp không?`,
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#4f46e5',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Nộp ngay',
            cancelButtonText: 'Làm tiếp'
        }).then((result) => {
            if (result.isConfirmed) {
                finishQuiz();
            }
        });
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

        // Render lại để hiện màu đúng sai
        if (app.mode === 'exam') renderAllQuestions(); else renderOneQuestion(app.currentIndex);
        renderPalette();

        document.getElementById('res-score').innerText = `${score}/${app.questions.length}`;
        const percent = (score / app.questions.length);
        
        // Thông báo kết quả
        let msg = "Cố gắng hơn lần sau nhé!";
        if(percent >= 0.5) msg = "Khá tốt!";
        if(percent >= 0.8) msg = "Tuyệt vời!";
        document.getElementById('res-msg').innerText = msg;

        document.getElementById('result-modal').classList.remove('hidden');
        
        // Hiệu ứng pháo hoa nếu điểm cao
        if (percent >= 0.7) confetti({ particleCount: 150, spread: 70, origin: { y: 0.6 } });
    }

    function restartQuiz() {
        document.getElementById('result-modal').classList.add('hidden');
        startQuiz();
    }
    
    function reviewQuiz() { 
        document.getElementById('result-modal').classList.add('hidden'); 
    }
</script>
</asp:Content>

