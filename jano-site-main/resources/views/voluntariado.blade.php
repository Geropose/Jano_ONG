@extends('layouts.sumate')

@section('maincontent')
    <div class="row align-items-center">
        <div class="col-lg-5">
            <img
                    class="img-fluid rounded mb-5 mb-lg-0"
                    src="img/concientizacion.jpeg"
                    alt=""
            />
            <img
                    class="img-fluid rounded mb-5 mb-lg-0"
                    src="img/Voluntariado.jpeg"
                    alt=""
            />
        </div>
        <div class="col-lg-7">
            <div class="bg-light p-5"
                 style="border-radius: 5%">
                <h1 class="mb-3">Voluntariado:</h1>
                <p>
                    Si querés agregar a tu vida una actividad en la que involucres tu solidaridad, responsabilidad y
                    compromiso, podés elegir diversas tareas en las cuales desarrollarte, con tus tiempos y
                    posibilidades.
                </p>
                <button class="btn btn-primary px-4" data-toggle="modal" data-target="#ModalNoProfesionales">
                    Quiero ser parte!
                </button>
            </div>
        </div>
    </div>
    <x-modal.no-profesionales></x-modal.no-profesionales>

@endsection
