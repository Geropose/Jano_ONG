@extends('layouts.base')
@section('header')
    <div
            class="d-flex flex-column align-items-center justify-content-center"
            style="min-height: 200px"
    >
        <h3 class="display-3 font-weight-bold text-white">Apoyanos</h3>
        <div class="d-inline-flex text-white">
            <p class="m-0"><a class="text-white" href="home">Inicio</a></p>
            <p class="m-0 px-2">/</p>
            <p class="m-0">Apoyanos</p>
        </div>
    </div>
@endsection

@section('maincontent')
    <div class="row align-items-center">
        <div class="col-lg">
            <div class="bg-light p-5"
                 style="border-radius: 5%">
                <h1 class="mb-3">Tu empresa nos puede acompañar!</h1>
                <p class="text-justify">
                    Para poder desempeñar nuestra función, son necesarios recursos materiales y humanos,
                    los cuales son aportados en su mayoria por empresa y/o particulares que deciden apoyarnos.
                    Existen diferentes niveles de colaboración.
                </p>
                <button class="btn btn-primary px-4" data-toggle="modal" data-target="#ModalEmpresas">
                    Quiero ser parte!
                </button>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-lg-6 col-md-6 pb-1">
            <div
                    class="d-flex bg-light shadow-sm border border-primary rounded mb-4"
                    style="padding: 30px"
            >
                <div class="pl-4">
                    <h4>Voluntariado empresarial</h4>
                    <p class="m-0">
                        Alianza con la cual su empresa apoya con un programa de voluntariado las actividades que desarrollamos.
                    </p>
                </div>
            </div>
        </div>
        <div class="col-lg-6 col-md-6 pb-1">
            <div
                    class="d-flex bg-light shadow-sm border border-warning rounded mb-4"
                    style="padding: 30px"
            >
                <div class="pl-4">
                    <h4>Apoyo corporativo</h4>
                    <p class="m-0">
                        Su empresa aporta materia prima y "know how" fortaleciendo nuestros proyectos.
                    </p>
                </div>
            </div>
        </div>
        <div class="col-lg-6 col-md-6 pb-1">
            <div
                    class="d-flex bg-light shadow-sm border border-success rounded mb-4"
                    style="padding: 30px"
            >
                <div class="pl-4">
                    <h4>Apoyo financiero</h4>
                    <p class="m-0">
                        Este apoyo siempre es necesario, por lo que contamos con diversas alternativas que pueden interesarle.
                    </p>
                </div>
            </div>
        </div>
        <div class="col-lg-6 col-md-6 pb-1">
            <div
                    class="d-flex bg-light shadow-sm border border-danger rounded mb-4"
                    style="padding: 30px"
            >
                <div class="pl-4">
                    <h4>Alianza estratégica</h4>
                    <p class="m-0">
                        Integra los 3 conceptos anteriores, dando lugar a un vínculo mucho más directo, de beneficio mutuo.
                    </p>
                </div>
            </div>
        </div>
    </div>
    <div class="row align-items-center">
        <div class="col-lg-7">
            <div class="bg-light p-5">
                <p class="text-justify">
                    Cada una de las piezas contribuyen las herramientas necesarias para que cumplamos nuestra labor
                    y brindemos a los niños y sus familias lo que necesiten. Asimismo, se abre un abanico de posibilidades
                    para que cada aportante pueda sumarse desde el lugar de comodidad o elección que desee y sienta.

                </p>
                <p class="text-justify">
                    Poniendo el foco en el sector corporativo y sabiendo la importancia que está cobrando la RSE, nuestra
                    meta final es podeer sumar "Alianzas estratégicas" a través de las cuales podamos trabajar conjuntamente con
                    continuidad en el tiempo; para lo cual en primera instancia proponemos generar un vínculo que derivará
                    en la confianza suficiente como para que las empresas comiencen a sumarse en alguna actividad puntual para luego ir avanzando.
                </p>
            </div>
        </div>
        <div class="col-lg-5">
            <img
                    class="img-fluid rounded mb-5 mb-lg-0"
                    src="img/puzzle.jpg"
                    alt=""
            />
        </div>
    </div>
    <x-modal.empresas></x-modal.empresas>
@endsection
