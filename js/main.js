document.addEventListener('DOMContentLoaded', () => {
    // 1. HTML5 Canvas Interactive Particle Network Background
    const canvas = document.getElementById('particle-canvas');
    if (canvas) {
        const ctx = canvas.getContext('2d');
        let particles = [];
        let mouse = { x: null, y: null, radius: 150 };

        // Handle Resize
        function resizeCanvas() {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
            initParticles();
        }

        // Particle Class
        class Particle {
            constructor() {
                this.x = Math.random() * canvas.width;
                this.y = Math.random() * canvas.height;
                this.vx = (Math.random() - 0.5) * 0.5; // Speed multiplier
                this.vy = (Math.random() - 0.5) * 0.5;
                this.size = Math.random() * 2 + 1;
            }

            draw() {
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
                ctx.fillStyle = 'rgba(99, 102, 241, 0.4)';
                ctx.fill();
            }

            update() {
                // Bounce on walls
                if (this.x < 0 || this.x > canvas.width) this.vx = -this.vx;
                if (this.y < 0 || this.y > canvas.height) this.vy = -this.vy;
                
                this.x += this.vx;
                this.y += this.vy;

                // Mouse interaction (push away slightly)
                if (mouse.x && mouse.y) {
                    let dx = this.x - mouse.x;
                    let dy = this.y - mouse.y;
                    let distance = Math.hypot(dx, dy);
                    if (distance < mouse.radius) {
                        let force = (mouse.radius - distance) / mouse.radius;
                        let angle = Math.atan2(dy, dx);
                        this.x += Math.cos(angle) * force * 2;
                        this.y += Math.sin(angle) * force * 2;
                    }
                }
            }
        }

        function initParticles() {
            particles = [];
            let numberOfParticles = Math.floor((canvas.width * canvas.height) / 12000);
            // Cap at 100 particles for performance
            numberOfParticles = Math.min(numberOfParticles, 120);
            for (let i = 0; i < numberOfParticles; i++) {
                particles.push(new Particle());
            }
        }

        // Connect particles with lines
        function connect() {
            for (let a = 0; a < particles.length; a++) {
                for (let b = a; b < particles.length; b++) {
                    let dx = particles[a].x - particles[b].x;
                    let dy = particles[a].y - particles[b].y;
                    let distance = Math.hypot(dx, dy);

                    if (distance < 110) {
                        let alpha = (110 - distance) / 110 * 0.15;
                        ctx.strokeStyle = `rgba(99, 102, 241, ${alpha})`;
                        ctx.lineWidth = 1;
                        ctx.beginPath();
                        ctx.moveTo(particles[a].x, particles[a].y);
                        ctx.lineTo(particles[b].x, particles[b].y);
                        ctx.stroke();
                    }
                }
            }
        }

        // Animation Loop
        function animate() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            particles.forEach(p => {
                p.update();
                p.draw();
            });
            connect();
            requestAnimationFrame(animate);
        }

        // Listeners
        window.addEventListener('resize', resizeCanvas);
        window.addEventListener('mousemove', (e) => {
            mouse.x = e.clientX;
            mouse.y = e.clientY;
        });
        window.addEventListener('mouseout', () => {
            mouse.x = null;
            mouse.y = null;
        });

        // Initialize
        resizeCanvas();
        animate();
    }

    // 2. Typing Effect for Subtitle on Homepage
    const typingElement = document.getElementById('typing-subtitle');
    if (typingElement) {
        const text = "2026 科学上网与网络加速指南：目前最稳的专线机场与翻墙梯子深度评测。专为个人、跨境办公及 AI 开发者量身打造，畅享极致自由。";
        let index = 0;
        function type() {
            if (index < text.length) {
                typingElement.innerHTML += text.charAt(index);
                index++;
                setTimeout(type, 35);
            }
        }
        // Start typing
        setTimeout(type, 500);
    }

    // 3. FAQ Accordion Toggle
    const faqItems = document.querySelectorAll('.faq-item');
    if (faqItems.length > 0) {
        faqItems.forEach(item => {
            const btn = item.querySelector('.faq-question-btn');
            const answer = item.querySelector('.faq-answer');
            
            if (btn && answer) {
                btn.addEventListener('click', () => {
                    const isActive = item.classList.contains('active');
                    
                    // Close all other items
                    faqItems.forEach(otherItem => {
                        if (otherItem !== item) {
                            otherItem.classList.remove('active');
                            const otherAns = otherItem.querySelector('.faq-answer');
                            if (otherAns) otherAns.style.maxHeight = null;
                        }
                    });
                    
                    if (!isActive) {
                        item.classList.add('active');
                        answer.style.maxHeight = answer.scrollHeight + 'px';
                    } else {
                        item.classList.remove('active');
                        answer.style.maxHeight = null;
                    }
                });
            }
        });
    }

    // 4. Comparison Table Filter & Sort
    const filterProtocol = document.getElementById('filter-protocol');
    const filterStreaming = document.getElementById('filter-streaming');
    const sortTable = document.getElementById('sort-table');
    const compareTable = document.getElementById('compare-table-body');
    
    if (compareTable && filterProtocol && filterStreaming && sortTable) {
        const originalRows = Array.from(compareTable.querySelectorAll('tr'));
        
        function updateTable() {
            const protocolVal = filterProtocol.value;
            const streamingVal = filterStreaming.value;
            const sortVal = sortTable.value;
            
            // Filter
            let filteredRows = originalRows.filter(row => {
                const rowProtocols = row.getAttribute('data-protocols').split(',');
                const rowStreaming = row.getAttribute('data-streaming').split(',');
                
                const matchProtocol = (protocolVal === 'all') || rowProtocols.includes(protocolVal);
                const matchStreaming = (streamingVal === 'all') || rowStreaming.includes(streamingVal);
                
                return matchProtocol && matchStreaming;
            });
            
            // Sort
            if (sortVal === 'price-asc') {
                filteredRows.sort((a, b) => {
                    return parseFloat(a.getAttribute('data-price')) - parseFloat(b.getAttribute('data-price'));
                });
            } else if (sortVal === 'price-desc') {
                filteredRows.sort((a, b) => {
                    return parseFloat(b.getAttribute('data-price')) - parseFloat(a.getAttribute('data-price'));
                });
            } else if (sortVal === 'date-desc') {
                filteredRows.sort((a, b) => {
                    const dateA = new Date(a.getAttribute('data-date'));
                    const dateB = new Date(b.getAttribute('data-date'));
                    return dateB - dateA;
                });
            }
            
            // Clear and Render
            compareTable.innerHTML = '';
            if (filteredRows.length === 0) {
                const noResultRow = document.createElement('tr');
                noResultRow.innerHTML = `<td colspan="6" style="text-align: center; padding: 40px; color: var(--text-muted);">
                    没有找到符合筛选条件的加速服务商
                </td>`;
                compareTable.appendChild(noResultRow);
            } else {
                filteredRows.forEach(row => {
                    compareTable.appendChild(row);
                });
            }
        }
        
        filterProtocol.addEventListener('change', updateTable);
        filterStreaming.addEventListener('change', updateTable);
        sortTable.addEventListener('change', updateTable);

        // Initial render on page load
        updateTable();
    }
    // 5. Redirect on Homepage Scroll
    const isHomepage = document.getElementById('typing-subtitle') !== null;
    if (isHomepage) {
        let isRedirecting = false;
        function redirectToBlog() {
            if (!isRedirecting) {
                isRedirecting = true;
                window.location.href = 'blog.html';
            }
        }

        // Mouse Wheel Redirect
        window.addEventListener('wheel', (e) => {
            if (e.deltaY > 0) {
                redirectToBlog();
            }
        }, { passive: true });

        // Touch Swipe Redirect for Mobile
        let touchStartY = 0;
        window.addEventListener('touchstart', (e) => {
            touchStartY = e.touches[0].pageY;
        }, { passive: true });

        window.addEventListener('touchmove', (e) => {
            let touchEndY = e.touches[0].pageY;
            if (touchStartY - touchEndY > 50) { // Swiped up (meaning scrolling down)
                redirectToBlog();
            }
        }, { passive: true });

        // Keyboard Scroll Redirect (backup)
        window.addEventListener('keydown', (e) => {
            if (e.key === 'PageDown' || e.key === 'ArrowDown' || e.key === ' ') {
                redirectToBlog();
            }
        });
    }

    // 6. Pricing Tab Filter for Review Pages
    const pricingTabBtns = document.querySelectorAll('.pricing-tab-btn');
    const pricingCards = document.querySelectorAll('.pricing-card-item');
    if (pricingTabBtns.length > 0 && pricingCards.length > 0) {
        pricingTabBtns.forEach(btn => {
            btn.addEventListener('click', () => {
                // Remove active class from all buttons
                pricingTabBtns.forEach(b => b.classList.remove('active'));
                // Add active class to clicked button
                btn.classList.add('active');
                
                const filter = btn.getAttribute('data-filter');
                pricingCards.forEach(card => {
                    const cardType = card.getAttribute('data-type');
                    if (filter === 'all' || cardType === filter) {
                        card.style.display = 'block';
                    } else {
                        card.style.display = 'none';
                    }
                });
            });
        });
    }
});
