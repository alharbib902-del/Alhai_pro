/* ============================================
   Alhai Documentation Site - Main JavaScript
   ============================================ */

(function () {
  'use strict';

  /* ============================================
     1. Dark Mode Toggle
     ============================================ */
  const ThemeManager = {
    STORAGE_KEY: 'alhai-docs-theme',

    init() {
      const saved = localStorage.getItem(this.STORAGE_KEY);
      if (saved) {
        this.set(saved, false);
      } else {
        const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
        this.set(prefersDark ? 'dark' : 'light', false);
      }

      // Listen for system preference changes
      window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
        if (!localStorage.getItem(this.STORAGE_KEY)) {
          this.set(e.matches ? 'dark' : 'light', false);
        }
      });

      // Bind toggle button
      const toggleBtn = document.getElementById('theme-toggle');
      if (toggleBtn) {
        toggleBtn.addEventListener('click', () => this.toggle());
      }
    },

    get() {
      return document.documentElement.getAttribute('data-theme') || 'light';
    },

    set(theme, save = true) {
      document.documentElement.setAttribute('data-theme', theme);
      if (save) {
        localStorage.setItem(this.STORAGE_KEY, theme);
      }
      this.updateIcon(theme);
      this.updateMermaid(theme);
    },

    toggle() {
      const current = this.get();
      this.set(current === 'dark' ? 'light' : 'dark');
    },

    updateIcon(theme) {
      const toggleBtn = document.getElementById('theme-toggle');
      if (!toggleBtn) return;
      const icon = toggleBtn.querySelector('i');
      if (!icon) return;
      if (theme === 'dark') {
        icon.className = 'fa-solid fa-sun';
        toggleBtn.setAttribute('title', 'الوضع الفاتح');
      } else {
        icon.className = 'fa-solid fa-moon';
        toggleBtn.setAttribute('title', 'الوضع الداكن');
      }
    },

    updateMermaid(theme) {
      if (typeof mermaid !== 'undefined') {
        try {
          mermaid.initialize({
            startOnLoad: false,
            theme: theme === 'dark' ? 'dark' : 'default',
            flowchart: { useMaxWidth: true },
          });
          // Re-render existing mermaid diagrams
          const diagrams = document.querySelectorAll('.mermaid[data-processed]');
          diagrams.forEach((el) => {
            el.removeAttribute('data-processed');
          });
          // We delay re-rendering to avoid race conditions
          setTimeout(() => {
            try {
              mermaid.run();
            } catch (_) {
              // Silently fail on re-render
            }
          }, 100);
        } catch (_) {
          // mermaid not available
        }
      }
    },
  };

  /* ============================================
     2. Sidebar
     ============================================ */
  const Sidebar = {
    init() {
      this.sidebar = document.getElementById('sidebar');
      this.overlay = document.getElementById('sidebar-overlay');
      this.toggleBtn = document.getElementById('sidebar-toggle');

      if (this.toggleBtn) {
        this.toggleBtn.addEventListener('click', () => this.toggle());
      }
      if (this.overlay) {
        this.overlay.addEventListener('click', () => this.close());
      }

      this.highlightCurrentPage();
      this.bindMobileClose();
    },

    toggle() {
      if (!this.sidebar) return;
      this.sidebar.classList.toggle('open');
      if (this.overlay) {
        this.overlay.classList.toggle('active');
      }
    },

    close() {
      if (!this.sidebar) return;
      this.sidebar.classList.remove('open');
      if (this.overlay) {
        this.overlay.classList.remove('active');
      }
    },

    highlightCurrentPage() {
      const links = document.querySelectorAll('.sidebar-nav a');
      const currentPath = window.location.pathname;
      const currentHref = window.location.href;

      links.forEach((link) => {
        link.classList.remove('active');
        const href = link.getAttribute('href');
        if (!href) return;

        // Resolve the link's href to full URL for comparison
        const linkUrl = new URL(href, window.location.href).href;

        if (
          currentHref === linkUrl ||
          currentHref.endsWith(href) ||
          (href === 'index.html' && (currentPath.endsWith('/') || currentPath.endsWith('/index.html')))
        ) {
          link.classList.add('active');
        }
      });
    },

    bindMobileClose() {
      const links = document.querySelectorAll('.sidebar-nav a');
      links.forEach((link) => {
        link.addEventListener('click', () => {
          if (window.innerWidth <= 768) {
            this.close();
          }
        });
      });
    },
  };

  /* ============================================
     3. Table of Contents (TOC) Generation
     ============================================ */
  const TOC = {
    headings: [],
    observer: null,

    init() {
      const tocContainer = document.getElementById('toc-list');
      const content = document.querySelector('.content');
      if (!tocContainer || !content) return;

      const headings = content.querySelectorAll('h2, h3');
      if (headings.length === 0) {
        // Hide TOC if there are no headings
        const toc = document.querySelector('.toc');
        if (toc) toc.style.display = 'none';
        return;
      }

      const fragment = document.createDocumentFragment();

      headings.forEach((heading, index) => {
        // Ensure heading has an ID
        if (!heading.id) {
          heading.id = 'heading-' + index;
        }

        const li = document.createElement('li');
        if (heading.tagName === 'H3') {
          li.classList.add('toc-h3');
        }

        const a = document.createElement('a');
        a.href = '#' + heading.id;
        a.textContent = heading.textContent;
        a.addEventListener('click', (e) => {
          e.preventDefault();
          heading.scrollIntoView({ behavior: 'smooth', block: 'start' });
          // Update URL hash without jumping
          history.pushState(null, null, '#' + heading.id);
        });

        li.appendChild(a);
        fragment.appendChild(li);

        this.headings.push({ el: heading, link: a });
      });

      tocContainer.appendChild(fragment);

      // Scroll spy with IntersectionObserver
      this.setupScrollSpy();
    },

    setupScrollSpy() {
      if (this.headings.length === 0) return;

      const observerOptions = {
        root: null,
        rootMargin: '-80px 0px -60% 0px',
        threshold: 0,
      };

      let activeIndex = -1;

      this.observer = new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
          const idx = this.headings.findIndex((h) => h.el === entry.target);
          if (entry.isIntersecting && idx !== -1) {
            activeIndex = idx;
          }
        });

        // Update active link
        this.headings.forEach((h, i) => {
          if (i === activeIndex) {
            h.link.classList.add('active');
          } else {
            h.link.classList.remove('active');
          }
        });
      }, observerOptions);

      this.headings.forEach((h) => {
        this.observer.observe(h.el);
      });
    },
  };

  /* ============================================
     4. Search
     ============================================ */
  const Search = {
    init() {
      this.input = document.getElementById('search-input');
      this.results = document.getElementById('search-results');
      if (!this.input || !this.results) return;

      this.input.addEventListener('input', () => this.handleSearch());
      this.input.addEventListener('focus', () => {
        if (this.input.value.trim().length > 0) {
          this.handleSearch();
        }
      });

      // Close results on click outside
      document.addEventListener('click', (e) => {
        if (!this.input.contains(e.target) && !this.results.contains(e.target)) {
          this.results.classList.remove('active');
        }
      });

      // Keyboard shortcut: Ctrl+K or Cmd+K to focus search
      document.addEventListener('keydown', (e) => {
        if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
          e.preventDefault();
          this.input.focus();
        }
        if (e.key === 'Escape') {
          this.results.classList.remove('active');
          this.input.blur();
        }
      });
    },

    handleSearch() {
      const query = this.input.value.trim();
      if (query.length < 2) {
        this.results.classList.remove('active');
        this.results.innerHTML = '';
        return;
      }

      const content = document.querySelector('.content');
      if (!content) return;

      const matches = [];
      const textElements = content.querySelectorAll('h1, h2, h3, h4, p, li, td, th');

      textElements.forEach((el) => {
        const text = el.textContent;
        const lowerText = text.toLowerCase();
        const lowerQuery = query.toLowerCase();
        const index = lowerText.indexOf(lowerQuery);

        if (index !== -1) {
          // Get surrounding context
          const start = Math.max(0, index - 30);
          const end = Math.min(text.length, index + query.length + 50);
          let snippet = (start > 0 ? '...' : '') + text.slice(start, end) + (end < text.length ? '...' : '');

          // Find closest heading for title
          let title = '';
          let headingEl = el;
          while (headingEl && !headingEl.matches('h1, h2, h3')) {
            headingEl = headingEl.previousElementSibling;
          }
          if (!headingEl) {
            // Try parent
            const parentSection = el.closest('section') || el.closest('.content');
            if (parentSection) {
              const h = parentSection.querySelector('h1, h2, h3');
              if (h) headingEl = h;
            }
          }
          title = headingEl ? headingEl.textContent : el.tagName.match(/^H\d$/) ? el.textContent : '';

          // Highlight match in snippet
          const regex = new RegExp('(' + query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + ')', 'gi');
          snippet = snippet.replace(regex, '<mark>$1</mark>');

          matches.push({
            title: title || 'نتيجة',
            snippet,
            target: headingEl || el,
          });
        }
      });

      // Deduplicate by title
      const unique = [];
      const seen = new Set();
      matches.forEach((m) => {
        const key = m.title + m.snippet;
        if (!seen.has(key)) {
          seen.add(key);
          unique.push(m);
        }
      });

      this.renderResults(unique.slice(0, 8));
    },

    renderResults(matches) {
      this.results.innerHTML = '';
      if (matches.length === 0) {
        const empty = document.createElement('div');
        empty.className = 'search-result-item';
        empty.innerHTML = '<span class="result-title">لا توجد نتائج</span>';
        this.results.appendChild(empty);
        this.results.classList.add('active');
        return;
      }

      matches.forEach((match) => {
        const item = document.createElement('div');
        item.className = 'search-result-item';
        item.innerHTML = `
          <div class="result-title">${match.title}</div>
          <div class="result-snippet">${match.snippet}</div>
        `;
        item.addEventListener('click', () => {
          match.target.scrollIntoView({ behavior: 'smooth', block: 'start' });
          this.results.classList.remove('active');
          this.input.value = '';
        });
        this.results.appendChild(item);
      });

      this.results.classList.add('active');
    },
  };

  /* ============================================
     5. Copy Code Button
     ============================================ */
  const CopyCode = {
    init() {
      const blocks = document.querySelectorAll('pre > code');
      blocks.forEach((codeBlock) => {
        const pre = codeBlock.parentElement;
        if (!pre) return;

        const btn = document.createElement('button');
        btn.className = 'copy-btn';
        btn.textContent = 'نسخ';
        btn.setAttribute('title', 'نسخ الكود');

        btn.addEventListener('click', () => {
          const text = codeBlock.textContent;
          navigator.clipboard
            .writeText(text)
            .then(() => {
              btn.textContent = 'تم النسخ!';
              btn.classList.add('copied');
              setTimeout(() => {
                btn.textContent = 'نسخ';
                btn.classList.remove('copied');
              }, 2000);
            })
            .catch(() => {
              // Fallback for older browsers
              const textarea = document.createElement('textarea');
              textarea.value = text;
              textarea.style.position = 'fixed';
              textarea.style.opacity = '0';
              document.body.appendChild(textarea);
              textarea.select();
              try {
                document.execCommand('copy');
                btn.textContent = 'تم النسخ!';
                btn.classList.add('copied');
                setTimeout(() => {
                  btn.textContent = 'نسخ';
                  btn.classList.remove('copied');
                }, 2000);
              } catch (_) {
                btn.textContent = 'فشل النسخ';
              }
              document.body.removeChild(textarea);
            });
        });

        pre.appendChild(btn);
      });
    },
  };

  /* ============================================
     6. Mermaid.js Initialization
     ============================================ */
  const MermaidInit = {
    init() {
      if (typeof mermaid === 'undefined') return;

      const currentTheme = ThemeManager.get();
      mermaid.initialize({
        startOnLoad: true,
        theme: currentTheme === 'dark' ? 'dark' : 'default',
        flowchart: { useMaxWidth: true },
        securityLevel: 'loose',
      });
    },
  };

  /* ============================================
     7. Smooth Scrolling for Anchor Links
     ============================================ */
  const SmoothScroll = {
    init() {
      document.addEventListener('click', (e) => {
        const link = e.target.closest('a[href^="#"]');
        if (!link) return;

        const targetId = link.getAttribute('href').slice(1);
        if (!targetId) return;

        const target = document.getElementById(targetId);
        if (!target) return;

        e.preventDefault();
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
        history.pushState(null, null, '#' + targetId);
      });
    },
  };

  /* ============================================
     8. Back to Top Button
     ============================================ */
  const BackToTop = {
    init() {
      const btn = document.getElementById('back-to-top');
      if (!btn) return;

      window.addEventListener('scroll', () => {
        if (window.scrollY > 400) {
          btn.classList.add('visible');
        } else {
          btn.classList.remove('visible');
        }
      });

      btn.addEventListener('click', () => {
        window.scrollTo({ top: 0, behavior: 'smooth' });
      });
    },
  };

  /* ============================================
     Initialize Everything on DOM Ready
     ============================================ */
  document.addEventListener('DOMContentLoaded', () => {
    ThemeManager.init();
    Sidebar.init();
    TOC.init();
    Search.init();
    CopyCode.init();
    MermaidInit.init();
    SmoothScroll.init();
    BackToTop.init();
  });
})();
