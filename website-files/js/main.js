/**
 * AWS S3 Portfolio - Main JavaScript
 * Main functionality for the website
 */

// Wait for DOM to be fully loaded
document.addEventListener("DOMContentLoaded", function () {
  console.log("☁️ AWS S3 Portfolio loaded successfully!");

  // Initialize all features
  initMobileMenu();
  initSmoothScroll();
  initActiveNavigation();
  initSkillsAnimation();
  initScrollAnimations();
  initLanguageToggle();
});

/**
 * Mobile Menu Toggle
 */
function initMobileMenu() {
  const hamburger = document.querySelector(".hamburger");
  const navMenu = document.querySelector(".nav-menu");

  if (!hamburger || !navMenu) return;

  hamburger.addEventListener("click", function () {
    hamburger.classList.toggle("active");
    navMenu.classList.toggle("active");

    // Animate hamburger icon
    const spans = hamburger.querySelectorAll("span");
    if (hamburger.classList.contains("active")) {
      spans[0].style.transform = "rotate(45deg) translate(5px, 5px)";
      spans[1].style.opacity = "0";
      spans[2].style.transform = "rotate(-45deg) translate(7px, -6px)";
    } else {
      spans[0].style.transform = "none";
      spans[1].style.opacity = "1";
      spans[2].style.transform = "none";
    }
  });

  // Close menu when clicking on a link
  const navLinks = document.querySelectorAll(".nav-menu a");
  navLinks.forEach((link) => {
    link.addEventListener("click", function () {
      hamburger.classList.remove("active");
      navMenu.classList.remove("active");
      const spans = hamburger.querySelectorAll("span");
      spans[0].style.transform = "none";
      spans[1].style.opacity = "1";
      spans[2].style.transform = "none";
    });
  });
}

/**
 * Smooth Scrolling for Anchor Links
 */
function initSmoothScroll() {
  const links = document.querySelectorAll('a[href^="#"]');

  links.forEach((link) => {
    link.addEventListener("click", function (e) {
      const href = this.getAttribute("href");

      // Ignore empty hash links
      if (href === "#" || href === "") return;

      const target = document.querySelector(href);
      if (!target) return;

      e.preventDefault();

      const headerHeight = document.querySelector(".header")?.offsetHeight || 0;
      const targetPosition = target.offsetTop - headerHeight;

      window.scrollTo({
        top: targetPosition,
        behavior: "smooth",
      });
    });
  });
}

/**
 * Active Navigation Based on Scroll Position
 */
function initActiveNavigation() {
  const sections = document.querySelectorAll("section[id]");
  const navLinks = document.querySelectorAll(".nav-menu a");

  if (sections.length === 0 || navLinks.length === 0) return;

  function updateActiveNav() {
    const scrollPosition = window.scrollY + 100;

    sections.forEach((section) => {
      const sectionTop = section.offsetTop;
      const sectionHeight = section.offsetHeight;
      const sectionId = section.getAttribute("id");

      if (
        scrollPosition >= sectionTop &&
        scrollPosition < sectionTop + sectionHeight
      ) {
        navLinks.forEach((link) => {
          link.classList.remove("active");
          if (link.getAttribute("href") === `#${sectionId}`) {
            link.classList.add("active");
          }
        });
      }
    });
  }

  // Update on scroll
  window.addEventListener("scroll", updateActiveNav);

  // Initial update
  updateActiveNav();
}

/**
 * Animate Skill Bars on Scroll
 */
function initSkillsAnimation() {
  const skillBars = document.querySelectorAll(".skill-progress");

  if (skillBars.length === 0) return;

  const observerOptions = {
    threshold: 0.5,
    rootMargin: "0px",
  };

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        const progressBar = entry.target;
        const targetWidth = progressBar.style.width;

        // Reset width
        progressBar.style.width = "0%";

        // Animate to target width
        setTimeout(() => {
          progressBar.style.width = targetWidth;
        }, 100);

        // Unobserve after animation
        observer.unobserve(progressBar);
      }
    });
  }, observerOptions);

  skillBars.forEach((bar) => observer.observe(bar));
}

/**
 * Scroll Animations for Elements
 */
function initScrollAnimations() {
  const animatedElements = document.querySelectorAll(
    ".feature-card, .demo-card, .skill-item"
  );

  if (animatedElements.length === 0) return;

  const observerOptions = {
    threshold: 0.1,
    rootMargin: "0px 0px -50px 0px",
  };

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.style.opacity = "0";
        entry.target.style.transform = "translateY(20px)";

        setTimeout(() => {
          entry.target.style.transition =
            "opacity 0.6s ease, transform 0.6s ease";
          entry.target.style.opacity = "1";
          entry.target.style.transform = "translateY(0)";
        }, 100);

        observer.unobserve(entry.target);
      }
    });
  }, observerOptions);

  animatedElements.forEach((element) => observer.observe(element));
}

/**
 * Language Toggle (English ↔ Arabic / LTR ↔ RTL)
 */

var translations = {
  en: {
    "page-title": "AWS S3 Portfolio Project | Cloud Engineering",
    "nav-home": "Home",
    "nav-features": "Features",
    "nav-architecture": "Architecture",
    "nav-demo": "Demo",
    "nav-contact": "Contact",
    "hero-title": "AWS S3 Static Website Hosting",
    "hero-subtitle": "Professional Cloud Engineering Portfolio Project",
    "hero-desc": "Demonstrating enterprise-grade static website hosting with security, disaster recovery, and cost optimization using Amazon S3",
    "btn-demo": "View Demo",
    "btn-github": "View on GitHub",
    "stat-uptime": "Uptime SLA",
    "stat-cost": "Cost Savings",
    "stat-load": "Load Time",
    "features-title": "Key Features",
    "features-subtitle": "Enterprise-level capabilities implemented",
    "f1-title": "Static Website Hosting",
    "f1-desc": "Serverless architecture with automatic scaling and global availability through AWS S3",
    "f2-title": "Multi-Layer Security",
    "f2-desc": "SSE-S3 encryption, IAM policies, bucket policies, and versioning for data protection",
    "f3-title": "Disaster Recovery",
    "f3-desc": "Cross-region replication with automated failover and 15-minute RPO",
    "f4-title": "Cost Optimization",
    "f4-desc": "Intelligent lifecycle policies, storage tiering, and 95% cost reduction",
    "f5-title": "Monitoring & Logging",
    "f5-desc": "CloudWatch metrics, access logs, and real-time performance monitoring",
    "f6-title": "High Performance",
    "f6-desc": "Sub-200ms load times with optimized content delivery and caching",
    "arch-title": "Architecture Overview",
    "arch-subtitle": "How everything works together",
    "arch-diagram-title": "📐 Architecture Diagram",
    "arch-diagram-sub": "See full documentation on GitHub",
    "arch-stack-h": "Technical Stack",
    "arch-storage": "Storage:",
    "arch-security": "Security:",
    "arch-dr": "DR:",
    "arch-monitoring": "Monitoring:",
    "arch-mgmt": "Management:",
    "arch-frontend": "Frontend:",
    "arch-metrics-h": "Key Metrics",
    "demo-title": "Live Demo & Resources",
    "demo-subtitle": "Explore the project",
    "d1-title": "📹 Video Demo",
    "d1-desc": "Watch the complete walkthrough and setup guide",
    "d1-btn": "Watch Video",
    "d2-title": "💻 GitHub Repository",
    "d2-desc": "Access all code, scripts, and documentation",
    "d2-btn": "View Code",
    "d3-title": "📚 Documentation",
    "d3-desc": "Comprehensive guides and architecture details",
    "d3-btn": "Read Docs",
    "d4-title": "📊 Performance Report",
    "d4-desc": "View detailed performance and security analysis",
    "d4-btn": "View Report",
    "skills-title": "Skills Demonstrated",
    "skill-security": "Cloud Security",
    "skill-dr": "Disaster Recovery",
    "skill-devops": "DevOps Practices",
    "skill-cost": "Cost Optimization",
    "contact-title": "Get In Touch",
    "contact-subtitle": "Let's connect and collaborate",
    "contact-email": "Email",
    "contact-portfolio": "Portfolio",
    "footer-copy": "© 2025 Mohammad Elgizawy. All rights reserved.",
    "footer-built": "Built with ❤️ and ☁️ AWS S3",
    "footer-license": "License",
    "footer-docs": "Documentation",
  },
  ar: {
    "page-title": "مشروع AWS S3 | هندسة السحابة",
    "nav-home": "الرئيسية",
    "nav-features": "المميزات",
    "nav-architecture": "المعمارية",
    "nav-demo": "التجربة",
    "nav-contact": "تواصل",
    "hero-title": "استضافة موقع ثابت على AWS S3",
    "hero-subtitle": "مشروع محفظة هندسة السحابة الاحترافية",
    "hero-desc": "استعراض استضافة المواقع الثابتة على مستوى المؤسسات مع الأمان والتعافي من الكوارث وتحسين التكاليف باستخدام Amazon S3",
    "btn-demo": "عرض تجريبي",
    "btn-github": "عرض على GitHub",
    "stat-uptime": "اتفاقية التشغيل",
    "stat-cost": "توفير التكاليف",
    "stat-load": "وقت التحميل",
    "features-title": "المميزات الرئيسية",
    "features-subtitle": "قدرات على مستوى المؤسسات",
    "f1-title": "استضافة مواقع ثابتة",
    "f1-desc": "معمارية بدون خادم مع التوسع التلقائي والتوافر العالمي عبر AWS S3",
    "f2-title": "أمان متعدد الطبقات",
    "f2-desc": "تشفير SSE-S3 وسياسات IAM وسياسات الحاوية والإصدار لحماية البيانات",
    "f3-title": "التعافي من الكوارث",
    "f3-desc": "النسخ المتقاطع عبر المناطق مع التبديل التلقائي ونقطة استرداد 15 دقيقة",
    "f4-title": "تحسين التكاليف",
    "f4-desc": "سياسات دورة حياة ذكية وطبقات التخزين وتخفيض التكلفة بنسبة 95٪",
    "f5-title": "المراقبة والتسجيل",
    "f5-desc": "مقاييس CloudWatch وسجلات الوصول ومراقبة الأداء في الوقت الفعلي",
    "f6-title": "أداء عالٍ",
    "f6-desc": "أوقات تحميل أقل من 200 ميلي ثانية مع تسليم المحتوى المحسَّن والتخزين المؤقت",
    "arch-title": "نظرة عامة على المعمارية",
    "arch-subtitle": "كيف يعمل كل شيء معاً",
    "arch-diagram-title": "📐 مخطط المعمارية",
    "arch-diagram-sub": "راجع التوثيق الكامل على GitHub",
    "arch-stack-h": "المكدس التقني",
    "arch-storage": "التخزين:",
    "arch-security": "الأمان:",
    "arch-dr": "التعافي:",
    "arch-monitoring": "المراقبة:",
    "arch-mgmt": "الإدارة:",
    "arch-frontend": "الواجهة:",
    "arch-metrics-h": "المقاييس الرئيسية",
    "demo-title": "العرض المباشر والموارد",
    "demo-subtitle": "استكشف المشروع",
    "d1-title": "📹 فيديو تجريبي",
    "d1-desc": "شاهد الجولة الكاملة ودليل الإعداد",
    "d1-btn": "مشاهدة الفيديو",
    "d2-title": "💻 مستودع GitHub",
    "d2-desc": "الوصول إلى جميع الأكواد والسكريبتات والتوثيق",
    "d2-btn": "عرض الكود",
    "d3-title": "📚 التوثيق",
    "d3-desc": "أدلة شاملة وتفاصيل المعمارية",
    "d3-btn": "قراءة التوثيق",
    "d4-title": "📊 تقرير الأداء",
    "d4-desc": "عرض تحليل الأداء والأمان التفصيلي",
    "d4-btn": "عرض التقرير",
    "skills-title": "المهارات المُثبَتة",
    "skill-security": "أمان السحابة",
    "skill-dr": "التعافي من الكوارث",
    "skill-devops": "ممارسات DevOps",
    "skill-cost": "تحسين التكاليف",
    "contact-title": "تواصل معنا",
    "contact-subtitle": "لنتواصل ونتعاون",
    "contact-email": "البريد الإلكتروني",
    "contact-portfolio": "المحفظة",
    "footer-copy": "© 2025 محمد الجيزاوي. جميع الحقوق محفوظة.",
    "footer-built": "بُني بـ ❤️ و ☁️ AWS S3",
    "footer-license": "الترخيص",
    "footer-docs": "التوثيق",
  },
};

function initLanguageToggle() {
  var langBtn = document.getElementById("lang-toggle");
  if (!langBtn) return;

  var htmlEl = document.documentElement;

  // Restore saved preference
  var savedLang = localStorage.getItem("preferred-lang");
  if (savedLang === "ar") {
    applyLanguage("ar");
  } else {
    applyLanguage("en");
  }

  langBtn.addEventListener("click", function () {
    var isArabic = htmlEl.getAttribute("lang") === "ar";
    applyLanguage(isArabic ? "en" : "ar");
  });

  function applyTranslations(lang) {
    var t = translations[lang];
    if (!t) return;
    document.querySelectorAll("[data-i18n]").forEach(function (el) {
      var key = el.getAttribute("data-i18n");
      if (t[key] !== undefined) {
        el.textContent = t[key];
      }
    });
    if (t["page-title"]) {
      document.title = t["page-title"];
    }
  }

  function applyLanguage(lang) {
    if (lang === "ar") {
      htmlEl.setAttribute("lang", "ar");
      htmlEl.setAttribute("dir", "rtl");
      langBtn.textContent = "English";
      langBtn.setAttribute("aria-label", "Switch to English");
    } else {
      htmlEl.setAttribute("lang", "en");
      htmlEl.setAttribute("dir", "ltr");
      langBtn.textContent = "عربي";
      langBtn.setAttribute("aria-label", "Switch to Arabic");
    }
    applyTranslations(lang);
    localStorage.setItem("preferred-lang", lang);
  }
}

/**
 * Scroll to Top Button (Optional)
 */
function initScrollToTop() {
  // Create button element
  const scrollBtn = document.createElement("button");
  scrollBtn.innerHTML = "↑";
  scrollBtn.className = "scroll-to-top";
  scrollBtn.setAttribute("aria-label", "Scroll to top");
  document.body.appendChild(scrollBtn);

  // Add styles
  const style = document.createElement("style");
  style.textContent = `
        .scroll-to-top {
            position: fixed;
            bottom: 30px;
            right: 30px;
            width: 50px;
            height: 50px;
            background-color: #FF9900;
            color: white;
            border: none;
            border-radius: 50%;
            font-size: 24px;
            cursor: pointer;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s ease;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            z-index: 999;
        }
        
        .scroll-to-top.visible {
            opacity: 1;
            visibility: visible;
        }
        
        .scroll-to-top:hover {
            background-color: #e68a00;
            transform: translateY(-5px);
        }
    `;
  document.head.appendChild(style);

  // Show/hide button based on scroll position
  window.addEventListener("scroll", () => {
    if (window.scrollY > 300) {
      scrollBtn.classList.add("visible");
    } else {
      scrollBtn.classList.remove("visible");
    }
  });

  // Scroll to top on click
  scrollBtn.addEventListener("click", () => {
    window.scrollTo({
      top: 0,
      behavior: "smooth",
    });
  });
}

// Initialize scroll to top button (optional - uncomment to enable)
// initScrollToTop();

/**
 * Performance Monitoring (Optional)
 */
function logPerformanceMetrics() {
  if ("performance" in window) {
    window.addEventListener("load", () => {
      setTimeout(() => {
        const perfData = performance.getEntriesByType("navigation")[0];

        if (perfData) {
          console.log("��� Performance Metrics:");
          console.log(
            `   DOM Content Loaded: ${
              perfData.domContentLoadedEventEnd -
              perfData.domContentLoadedEventStart
            }ms`
          );
          console.log(
            `   Page Load Complete: ${
              perfData.loadEventEnd - perfData.loadEventStart
            }ms`
          );
          console.log(
            `   Total Load Time: ${
              perfData.loadEventEnd - perfData.fetchStart
            }ms`
          );
        }
      }, 0);
    });
  }
}

// Log performance metrics (optional - uncomment to enable)
// logPerformanceMetrics();

/**
 * Console Message
 */
console.log(`
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║        ��� AWS S3 Portfolio Project                   ║
║                                                       ║
║        Interested in the code?                       ║
║        Check it out on GitHub!                       ║
║                                                       ║
║        ��� githumelgizawyername/AWS-S3-Static-Website-Hosting  ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
`);
