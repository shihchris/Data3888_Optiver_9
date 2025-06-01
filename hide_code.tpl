{% extends 'lab/index.html.j2' %}

{% block html_head %}
  {{ super() }}
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
  <style>
    :root {
      --primary-color: #2563eb;
      --secondary-color: #64748b;
      --accent-color: #06b6d4;
      --bg-primary: #ffffff;
      --bg-secondary: #f8fafc;
      --bg-tertiary: #f1f5f9;
      --text-primary: #1e293b;
      --text-secondary: #64748b;
      --border-color: #e2e8f0;
      --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
      --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
      --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
    }

    [data-theme="dark"] {
      --bg-primary: #0f172a;
      --bg-secondary: #1e293b;
      --bg-tertiary: #334155;
      --text-primary: #f1f5f9;
      --text-secondary: #94a3b8;
      --border-color: #334155;
    }

    [data-theme="dark"] .jp-OutputArea {
      background: var(--bg-secondary);
      color: var(--text-primary);
    }

    [data-theme="dark"] .jp-OutputArea pre,
    [data-theme="dark"] .jp-OutputArea code {
      background: var(--bg-tertiary);
      color: var(--text-primary);
    }

    [data-theme="dark"] .jp-CodeMirrorEditor,
    [data-theme="dark"] .CodeMirror {
      background: var(--bg-secondary) !important;
      color: var(--text-primary) !important;
    }

    [data-theme="dark"] .CodeMirror-gutters {
      background: var(--bg-tertiary) !important;
      border-right: 1px solid var(--border-color) !important;
    }

    [data-theme="dark"] .CodeMirror-linenumber {
      color: var(--text-secondary) !important;
    }

    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
      background: var(--bg-secondary);
      color: var(--text-primary);
      margin: 0;
      line-height: 1.6;
    }

    .notebook-header {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      background: var(--bg-primary);
      border-bottom: 1px solid var(--border-color);
      padding: 12px 24px;
      z-index: 1000;
      box-shadow: var(--shadow-sm);
      display: flex;
      align-items: center;
      justify-content: space-between;
    }

    .control-group {
      display: flex;
      gap: 12px;
      align-items: center;
    }

    .theme-controls {
      display: flex;
      align-items: center;
    }

    .control-btn {
      padding: 8px 16px;
      border: 1px solid var(--border-color);
      background: var(--bg-primary);
      color: var(--text-primary);
      border-radius: 6px;
      cursor: pointer;
      font-size: 14px;
      display: flex;
      align-items: center;
      gap: 6px;
      transition: all 0.2s ease;
      min-width: 130px;
      justify-content: center;
    }

    .control-btn:hover {
      background: var(--bg-tertiary);
      border-color: var(--primary-color);
    }

    .control-btn.active {
      background: var(--primary-color);
      color: white;
      border-color: var(--primary-color);
    }

    .toc-container {
      position: fixed;
      top: 80px;
      left: 24px;
      width: 280px;
      max-height: calc(100vh - 120px);
      background: var(--bg-primary);
      border: 1px solid var(--border-color);
      border-radius: 8px;
      box-shadow: var(--shadow-md);
      overflow: hidden;
      z-index: 100;
      transition: transform 0.3s ease;
    }

    .toc-container.hidden {
      transform: translateX(-100%);
    }

    .toc-header {
      padding: 16px 20px;
      background: var(--bg-tertiary);
      border-bottom: 1px solid var(--border-color);
      font-weight: 600;
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .toc-content {
      padding: 12px 0;
      max-height: 400px;
      overflow-y: auto;
    }

    .toc-item {
      display: block;
      padding: 8px 20px;
      color: var(--text-secondary);
      text-decoration: none;
      border-left: 3px solid transparent;
      transition: all 0.2s ease;
      font-size: 14px;
    }

    .toc-item:hover {
      background: var(--bg-tertiary);
      color: var(--text-primary);
    }

    .toc-item.active {
      color: var(--primary-color);
      border-left-color: var(--primary-color);
      background: var(--bg-tertiary);
    }

    .toc-item.level-1 { padding-left: 20px; font-weight: 600; }
    .toc-item.level-2 { padding-left: 32px; }
    .toc-item.level-3 { padding-left: 44px; }
    .toc-item.level-4 { padding-left: 56px; }

    .notebook-content {
      margin-top: 80px;
      margin-left: 320px;
      padding: 24px;
      transition: margin-left 0.3s ease;
    }

    .notebook-content.toc-hidden {
      margin-left: 24px;
    }

    .jp-Cell {
      background: var(--bg-primary);
      border: 1px solid var(--border-color);
      border-radius: 8px;
      margin-bottom: 16px;
      box-shadow: var(--shadow-sm);
      overflow: hidden;
    }

    .jp-InputArea {
    transition: all 0.3s ease;
    border-top: 1px solid var(--border-color);
    }

    .jp-CodeCell .jp-InputArea {
    display: none;
    }

    .jp-InputArea.collapsed {
      display: none;
    }

    .jp-InputArea.expanded {
      display: block;
    }

    .jp-OutputArea {
      border-top: 1px solid var(--border-color);
      transition: all 0.3s ease;
      display: none;
    }

    .jp-OutputArea.collapsed {
      display: none;
    }

    .jp-OutputArea.expanded {
      display: block;
    }

    .cell-header {
      padding: 8px 16px;
      background: var(--bg-tertiary);
      border-bottom: 1px solid var(--border-color);
      display: flex;
      align-items: center;
      justify-content: space-between;
      cursor: pointer;
      user-select: none;
      transition: background 0.2s ease;
    }

    .cell-header:hover {
      background: var(--bg-secondary);
    }

    .cell-type {
      font-size: 12px;
      color: var(--text-secondary);
      font-weight: 500;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }

    .fold-icon {
      color: var(--text-secondary);
      transition: transform 0.2s ease;
      transform: rotate(-90deg);
    }

    .fold-icon.collapsed {
      transform: rotate(-90deg);
    }

    .fold-icon.expanded {
      transform: rotate(0deg);
    }

    h1, h2, h3, h4, h5, h6 {
      color: var(--text-primary);
      margin-top: 2em;
      margin-bottom: 0.5em;
      scroll-margin-top: 100px;
    }

    h1 { 
      font-size: 2.25em; 
      border-bottom: 2px solid var(--border-color);
      padding-bottom: 0.5em;
    }
    h2 { 
      font-size: 1.75em; 
      border-bottom: 1px solid var(--border-color);
      padding-bottom: 0.25em;
    }
    h3 { font-size: 1.5em; }
    h4 { font-size: 1.25em; }

    .jp-CodeMirrorEditor {
      font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
      font-size: 14px;
      line-height: 1.5;
    }

    @media (max-width: 1024px) {
      .toc-container {
        width: 240px;
      }
      .notebook-content {
        margin-left: 264px;
      }
      .notebook-content.toc-hidden {
        margin-left: 24px;
      }
    }

    @media (max-width: 768px) {
      .notebook-header {
        padding: 8px 16px;
        flex-wrap: wrap;
        gap: 8px;
      }
      .control-group {
        flex-wrap: wrap;
        gap: 6px;
      }
      .control-btn {
        padding: 6px 10px;
        font-size: 12px;
        min-width: 100px;
      }
      .toc-container {
        width: 100%;
        left: 0;
        right: 0;
        top: 80px;
        max-height: 300px;
      }
      .notebook-content {
        margin-left: 0;
        padding: 16px;
        margin-top: 100px;
      }
    }

    .theme-toggle {
      background: none;
      border: 1px solid var(--border-color);
      color: var(--text-primary);
      padding: 8px;
      border-radius: 6px;
      cursor: pointer;
      transition: all 0.2s ease;
    }

    .theme-toggle:hover {
      background: var(--bg-tertiary);
    }

    .toc-content::-webkit-scrollbar {
      width: 6px;
    }

    .toc-content::-webkit-scrollbar-track {
      background: var(--bg-secondary);
    }

    .toc-content::-webkit-scrollbar-thumb {
      background: var(--border-color);
      border-radius: 3px;
    }

    .toc-content::-webkit-scrollbar-thumb:hover {
      background: var(--text-secondary);
    }
  </style>

  <script>
    document.addEventListener("DOMContentLoaded", function () {
      const header = document.createElement('div');
      header.className = 'notebook-header';
      
      const controlGroup = document.createElement('div');
      controlGroup.className = 'control-group';
      
      const themeControls = document.createElement('div');
      themeControls.className = 'theme-controls';

      const tocBtn = document.createElement('button');
      tocBtn.innerHTML = '<i class="fas fa-list"></i> Table of Contents';
      tocBtn.className = 'control-btn active';
      tocBtn.id = 'toc-toggle';
      
      const codeBtn = document.createElement('button');
      codeBtn.innerHTML = '<i class="fas fa-code"></i> Toggle Code';
      codeBtn.className = 'control-btn';
      codeBtn.id = 'code-toggle';
      
      const outputBtn = document.createElement('button');
      outputBtn.innerHTML = '<i class="fas fa-terminal"></i> Toggle Output';
      outputBtn.className = 'control-btn';
      outputBtn.id = 'output-toggle';

      const themeBtn = document.createElement('button');
      themeBtn.innerHTML = '<i class="fas fa-moon"></i>';
      themeBtn.className = 'theme-toggle';
      themeBtn.id = 'theme-toggle';

      controlGroup.appendChild(tocBtn);
      controlGroup.appendChild(codeBtn);
      controlGroup.appendChild(outputBtn);
      themeControls.appendChild(themeBtn);
      
      header.appendChild(controlGroup);
      header.appendChild(themeControls);
      document.body.insertBefore(header, document.body.firstChild);

      const tocContainer = document.createElement('div');
      tocContainer.className = 'toc-container';
      tocContainer.innerHTML = `
        <div class="toc-header">
          <i class="fas fa-list"></i>
          <span>Table of Contents</span>
        </div>
        <div class="toc-content" id="toc-content"></div>
      `;
      document.body.appendChild(tocContainer);

      const mainContent = document.querySelector('.jp-Notebook') || document.body;
      const contentWrapper = document.createElement('div');
      contentWrapper.className = 'notebook-content';
      mainContent.parentNode.insertBefore(contentWrapper, mainContent);
      contentWrapper.appendChild(mainContent);

      function setupCellFolding() {
        document.querySelectorAll('.jp-Cell').forEach((cell, index) => {
          if (cell.querySelector('.cell-header')) return;
          
          const header = document.createElement('div');
          header.className = 'cell-header';
          
          const isCodeCell = cell.classList.contains('jp-CodeCell');
          if (!isCodeCell) return;
          const cellType = 'Code';
                
          header.innerHTML = `
            <span class="cell-type">${cellType} Cell ${index + 1}</span>
            <i class="fas fa-chevron-down fold-icon"></i>
          `;
          
          cell.insertBefore(header, cell.firstChild);
          
          header.addEventListener('click', () => {
            const inputArea = cell.querySelector('.jp-InputArea');
            const outputArea = cell.querySelector('.jp-OutputArea');
            const icon = header.querySelector('.fold-icon');
            
            if (inputArea) {
              inputArea.classList.toggle('expanded');
            }
            if (outputArea && isCodeCell) {
              outputArea.classList.toggle('expanded');
            }
            if (icon) {
              icon.classList.toggle('expanded');
            }
          });
        });
      }

      function generateTOC() {
        const tocContent = document.getElementById('toc-content');
        const headings = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
        
        tocContent.innerHTML = '';
        
        if (headings.length === 0) {
          tocContent.innerHTML = '<div style="padding: 20px; text-align: center; color: var(--text-secondary);">No headings found</div>';
          return;
        }
        
        headings.forEach((heading, index) => {
          const level = parseInt(heading.tagName.substring(1));
          const text = heading.textContent.trim();
          const id = `heading-${index}`;
          
          heading.id = id;
          
          const tocItem = document.createElement('a');
          tocItem.href = `#${id}`;
          tocItem.className = `toc-item level-${level}`;
          tocItem.textContent = text;
          tocItem.addEventListener('click', (e) => {
            e.preventDefault();
            heading.scrollIntoView({ behavior: 'smooth', block: 'start' });
            
            document.querySelectorAll('.toc-item').forEach(item => item.classList.remove('active'));
            tocItem.classList.add('active');
          });
          
          tocContent.appendChild(tocItem);
        });
      }

      document.getElementById('toc-toggle').addEventListener('click', function() {
        const tocContainer = document.querySelector('.toc-container');
        const contentWrapper = document.querySelector('.notebook-content');
        
        tocContainer.classList.toggle('hidden');
        contentWrapper.classList.toggle('toc-hidden');
        this.classList.toggle('active');
      });

      document.getElementById('code-toggle').addEventListener('click', function() {
        document.querySelectorAll('.jp-CodeCell .jp-InputArea').forEach(cell => {
          cell.classList.toggle('expanded');
        });
        document.querySelectorAll('.jp-CodeCell .cell-header .fold-icon').forEach(icon => {
          icon.classList.toggle('expanded');
        });
        this.classList.toggle('active');
      });

      document.getElementById('output-toggle').addEventListener('click', function() {
        document.querySelectorAll('.jp-OutputArea').forEach(output => {
          output.classList.toggle('expanded');
        });
        document.querySelectorAll('.jp-CodeCell .cell-header .fold-icon').forEach(icon => {
          icon.classList.toggle('expanded');
        });
        this.classList.toggle('active');
      });

      document.getElementById('theme-toggle').addEventListener('click', function() {
        const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
        document.documentElement.setAttribute('data-theme', isDark ? 'light' : 'dark');
        this.innerHTML = isDark ? '<i class="fas fa-moon"></i>' : '<i class="fas fa-sun"></i>';
      });

      setTimeout(() => {
        setupCellFolding();
        generateTOC();
        
        let ticking = false;
        function updateActiveTOC() {
          const headings = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
          const scrollPosition = window.scrollY + 120;
          
          let activeHeading = null;
          headings.forEach(heading => {
            if (heading.offsetTop <= scrollPosition) {
              activeHeading = heading;
            }
          });
          
          document.querySelectorAll('.toc-item').forEach(item => item.classList.remove('active'));
          if (activeHeading) {
            const activeItem = document.querySelector(`.toc-item[href="#${activeHeading.id}"]`);
            if (activeItem) activeItem.classList.add('active');
          }
          ticking = false;
        }
        
        window.addEventListener('scroll', () => {
          if (!ticking) {
            requestAnimationFrame(updateActiveTOC);
            ticking = true;
          }
        });
      }, 500);
    });
  </script>
{% endblock %}