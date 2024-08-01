import './bootstrap';

import "@flaticon/flaticon-uicons/css/all/all.css";
import 'owl.carousel/dist/assets/owl.carousel.css';

import 'owl.carousel';
import 'lazysizes';

import 'lightbox2/dist/css/lightbox.css';
import 'lightbox2';

import 'jquery.easing';

import 'isotope-layout';


// Back to top button
$(window).scroll(function () {
    if ($(this).scrollTop() > 100) {
        $('.back-to-top').fadeIn('slow');
    } else {
        $('.back-to-top').fadeOut('slow');
    }
});
$('.back-to-top').click(function () {
    $('html, body').animate({scrollTop: 0}, 1500, 'easeInOutExpo');
    return false;
});

(function () {
    'use strict'
    let $portfolio = $('.portfolio-container');
    if ($portfolio.length > 0) {
        // Portfolio isotope and filter
        var portfolioIsotope = $portfolio.isotope({
            itemSelector: '.portfolio-item',
            layoutMode: 'fitRows'
        });

        let $portfolioFilters = $('#portfolio-flters li');
        $portfolioFilters.on('click', function () {
            $portfolioFilters.removeClass('active');
            $(this).addClass('active');

            portfolioIsotope.isotope({filter: $(this).data('filter')});
        });
    }
}
)(jQuery);

// Post carousel
$(".post-carousel").owlCarousel({
    autoplay: true,
    smartSpeed: 1500,
    dots: false,
    loop: true,
    nav: true,
    navText: [
        '<i class="fa fa-angle-left" aria-hidden="true"></i>',
        '<i class="fa fa-angle-right" aria-hidden="true"></i>'
    ],
    responsive: {
        0: {
            items: 1
        },
        576: {
            items: 1
        },
        768: {
            items: 2
        },
        992: {
            items: 2
        }
    }
});


// Testimonials carousel
$(".testimonial-carousel").owlCarousel({
    center: true,
    autoplay: true,
    smartSpeed: 2000,
    dots: true,
    loop: true,
    responsive: {
        0: {
            items: 1
        },
        576: {
            items: 1
        },
        768: {
            items: 2
        },
        992: {
            items: 3
        }
    }
});


(function () {
    'use strict'

    var forms = document.querySelectorAll('.needs-validation')

    Array.prototype.slice.call(forms)
        .forEach(function (form) {
            form.addEventListener('submit', function (event) {
                if (!form.checkValidity()) {
                    event.preventDefault()
                    event.stopPropagation()
                }

                form.classList.add('was-validated')
            }, false)
        })
})();

(function () {
    function $MPC_load() {
        window.$MPC_loaded !== true && (function () {
            var s = document.createElement("script");
            s.type = "text/javascript";
            s.async = true;
            s.src = document.location.protocol + "//secure.mlstatic.com/mptools/render.js";
            var x = document.getElementsByTagName('script')[0];
            x.parentNode.insertBefore(s, x);
            window.$MPC_loaded = true;
        })();
    }

    window.$MPC_loaded !== true ? (window.attachEvent ? window.attachEvent('onload', $MPC_load) : window.addEventListener('load', $MPC_load, false)) : null;
})();
/*
      // to receive event with message when closing modal from congrants back to site
      function $MPC_message(event) {
        // onclose modal ->CALLBACK FUNCTION
       // !!!!!!!!FUNCTION_CALLBACK HERE Received message: {event.data} preapproval_id !!!!!!!!
      }
      window.$MPC_loaded !== true ? (window.addEventListener("message", $MPC_message)) : null;
      */

/** Forms de envio de mailenviar **/
(function () {
    'use strict'

    var forms = document.querySelectorAll('form[action="enviar.php"]')


    Array.prototype.slice.call(forms)
        .forEach(function (form) {


            form.addEventListener('submit', function (event) {
                event.preventDefault()
                event.stopPropagation()

                var formData = new FormData(form);

                $.ajax({
                    url: $(form).attr('action'),
                    method: 'POST',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false
                }).done(function (data) {
                    console.log(data)
                    if (data.status === 'OK') {
                        $(form).removeClass('was-validated');
                        $(form).trigger('reset');
                        $(form).parent().before("<div class='alert alert-success'>" + data.message + " <button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-label=\"Close\">\n" +
                            "    <span aria-hidden=\"true\">&times;</span>\n" +
                            "  </button></div>");
                    } else
                        $(form).parent().before("<div class='alert alert-warning'>" + data.message + " <button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-label=\"Close\">\n" +
                            "    <span aria-hidden=\"true\">&times;</span>\n" +
                            "  </button></div>");
                })
                    .fail(function () {
                        $(form).parent().before("<div class='alert alert-danger'>Error desconocido en el envío <button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-label=\"Close\">\n" +
                            "    <span aria-hidden=\"true\">&times;</span>\n" +
                            "  </button></div>");
                    });

            }, false)
        })
})();
