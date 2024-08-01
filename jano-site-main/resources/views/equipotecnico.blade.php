@extends('layouts.sumate')
@section('maincontent')
    <div class="row align-items-center">
        <div class="col-lg">
            <div class="bg-light p-5"
                 style="border-radius: 5%">
                <h1 class="mb-3">Equipo técnico profesional:</h1>
                <p>
                    Si sos un profesional relacionado al Área Psicosocial, podés sumarte para ser parte del equipo que
                    trabaja desde la interdisciplina, abordando integralmente a las familias que acompañamos.
                </p>
                <button class="btn btn-primary px-4" data-toggle="modal" data-target="#ModalProfesionales">
                    Quiero ser parte!
                </button>
            </div>
        </div>
    </div>
    <x-modal.profesionales></x-modal.profesionales>
@endsection
