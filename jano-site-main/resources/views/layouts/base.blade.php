<!DOCTYPE html>
<html lang="es">
<head>
    @section('head')
        @vite(['resources/css/app.css'])
        <meta charset="utf-8"/>
        <title>Jano Por Todos</title>
        <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
        <link rel="shortcut icon" href="img/logo_jano_por_todos.png">
        <!-- Favicon -->
        <link href="img/favicon.ico" rel="icon"/>

        <!-- Google Web Fonts -->
        <link rel="preconnect" href="https://fonts.gstatic.com"/>
        <link
            href="https://fonts.googleapis.com/css2?family=Handlee&family=Nunito&display=swap"
            rel="stylesheet"
        />
        <script>
            // Selecting the iframe element
            var iframe = document.getElementById("myIframe");

            if (iframe) {
                iframe.onload = function () {
                    iframe.style.height = iframe.contentWindow.document.body.scrollHeight + 'px';
                }
            }
            // Adjusting the iframe height onload event
        </script>
        <!-- Font Awesome -->
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet"/>

    @show
</head>

<body>
<div class="container-fluid bg-light position-relative shadow">
    @section('mainnav')
        <x-mainnav></x-mainnav>
    @show
</div>

<div class="container-fluid bg-primary px-0 px-md-5 mb-5">
    @section('header')
        <div class="row align-items-center p-3">
            <div class="col-lg-6 text-center text-lg-left">
                <img class="rounded mx-auto d-bloc p-3" src="img/Junto_Al_Niño_Oncologico.png" width="80%">
                <p class="text-white mb-4">
                    Un niño con cáncer sigue siendo, sobre todo, un niño. Defendamos sus derechos.
                </p>
                <a href="quienesSomos" class="btn btn-secondary mt-1 py-3 px-5">Leer más</a>
            </div>
            <div class="col-lg-6 text-center text-lg-right">
                <img src="img/logoJano.jpg" width=90% alt=""/>
            </div>
        </div>
    @show
</div>

@section('modals')
    <x-modal.donaciones></x-modal.donaciones>
    <x-modal.suscripcion></x-modal.suscripcion>
    <x-modal.monto></x-modal.monto>

@show


<div class="container-fluid pt-5">
    <div class="container">
        @section('maincontent')

        @show
    </div>
</div>

<div
    class="container-fluid bg-secondary text-white mt-5 py-5 px-sm-3 px-md-5"
>
    @section('footer')
        <div class="row pt-5">
            <div class="col-lg-3 col-md-6 mb-5">
                <a
                    href=""
                    class="navbar-brand font-weight-bold text-primary m-0 mb-4 p-0"
                    style="font-size: 40px; line-height: 40px"
                >
                    <span class="text-white">Jano Por Todos</span>
                </a>
                <p>
                    Junto Al Niño Oncológico
                </p>
                <div class="d-flex justify-content-start mt-4">
                    <a
                        class="btn btn-outline-primary rounded-circle text-center mr-2 px-0"
                        style="width: 38px; height: 38px"
                        href="https://twitter.com/janoportodos?lang=es"
                    ><i class="fab fa-twitter"></i
                        ></a>
                    <a
                        class="btn btn-outline-primary rounded-circle text-center mr-2 px-0"
                        style="width: 38px; height: 38px"
                        href="https://www.facebook.com/JanoporTodosTandil/"
                    ><i class="fab fa-facebook-f"></i
                        ></a>
                    <a
                        class="btn btn-outline-primary rounded-circle text-center mr-2 px-0"
                        style="width: 38px; height: 38px"
                        href="https://www.instagram.com/janoportodos/"
                    ><i class="fab fa-instagram"></i
                        ></a>
                </div>
            </div>
            <div class="col-lg-3 col-md-6 mb-5">
                <h3 class="text-primary mb-4">Contacto</h3>
                <!-- <div class="d-flex">
                  <h4 class="fa fa-map-marker-alt text-primary"></h4>
                  <div class="pl-3">
                    <h5 class="text-white">Dirección</h5>
                    <a class="text-white" href="https://www.google.com/maps/place/Asoc.+Civil+Jano+por+Todos/@-37.307349,-59.1450807,15z/data=!4m6!3m5!1s0x9591217ecb8c7adf:0xd7ce21f66ccddb3a!8m2!3d-37.307349!4d-59.1450807!16s%2Fg%2F11gmv258mv">Moreno 1064, Tandil, Bs As</a>
                  </div>
                </div> -->
                <div class="d-flex">
                    <h4 class="fa fa-envelope text-primary"></h4>
                    <div class="pl-3">
                        <h5 class="text-white">Email</h5>
                        <p>janoportodos@gmail.com</p>
                    </div>
                </div>
                <div class="d-flex">
                    <h4 class="fa fa-phone-alt text-primary"></h4>
                    <div class="pl-3">
                        <h5 class="text-white">Teléfono</h5>
                        <p>+54 2494635221</p>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-md-6 mb-5">
                <h3 class="text-primary mb-4">Links recomendados</h3>
                <div class="d-flex flex-column justify-content-start">
                    <a class="text-white mb-2" href="quienesSomos"
                    ><i class="fa fa-angle-right mr-2"></i>Nosotros</a
                    >
                    <a class="text-white mb-2" href="juntoalasfamilias"
                    ><i class="fa fa-angle-right mr-2"></i>Programas</a
                    >
                    <a class="text-white mb-2" href="eventos"
                    ><i class="fa fa-angle-right mr-2"></i>Eventos</a
                    >
                    <a class="text-white mb-2" href="Equipotecnico"
                    ><i class="fa fa-angle-right mr-2"></i>Sumate</a
                    >
                    <a class="text-white mb-2" href="apoyanos"
                    ><i class="fa fa-angle-right mr-2"></i>Apoyanos</a
                    >
                    <a class="text-white mb-2" href="acercaDeCancerInfantoJuvenil"
                    ><i class="fa fa-angle-right mr-2"></i>Acerca de</a
                    >
                </div>
            </div>
            <div class="col-lg-3 col-md-6 mb-5">
                <h3 class="text-primary mb-4">Suscribirse a noticias</h3>
                <div>
                   <x-form.suscripcion></x-form.suscripcion>
                </div>
            </div>
        </div>
    @show




    @section('footer-disclaimer')
        <div
            class="container-fluid pt-5"
            style="border-top: 1px solid rgba(23, 162, 184, 0.2) ;"
        >
            <p class="m-0 text-center text-white">Descargo de responsabilidad: La información contenida en este sitio
                web es
                de carácter orientativo y no reemplaza las indicaciones o pautas brindadas por los profesionales.</p>
            <p class="m-0 text-center text-white">Jano Por Todos no asumirá ninguna responsabilidad sobre inexactitudes
                o
                usos inadecuados de los contenidos de su sitio web.</p>
            <p class="m-0 text-center text-white">
                &copy;
                <a class="text-primary font-weight-bold" href="#">Jano Por Todos</a>.
                Todos los derechos reservados.
        </div>
    @show


</div>

<a href="#" class="btn btn-primary p-3 back-to-top"><i class="fa fa-angle-double-up"></i></a>

@section('inline-scripts')

@show
@vite(['resources/js/app.js'])
</body>
</html>
