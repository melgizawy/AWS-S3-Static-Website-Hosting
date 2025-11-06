/**
 * AWS S3 Portfolio - Main JavaScript
 * Main functionality for the website
 */

// Wait for DOM to be fully loaded
document.addEventListener("DOMContentLoaded", function () {
  console.log("��� AWS S3 Portfolio loaded successfully!");

  // Initialize all features
  initMobileMenu();
  initSmoothScroll();
  initActiveNavigation();
  initSkillsAnimation();
  initScrollAnimations();
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
