@extends('layouts.base')
@section('header')
    <div
            class="d-flex flex-column align-items-center justify-content-center"
            style="min-height: 200px"
    >
        <h3 class="display-3 font-weight-bold text-white">Eventos</h3>
        <div class="d-inline-flex text-white">
            <p class="m-0"><a class="text-white" href="home">Inicio</a></p>
            <p class="m-0 px-2">/</p>
            <p class="m-0">Eventos</p>
        </div>
    </div>
@endsection

@section('maincontent')
    <div class="text-center pb-2">
        <p class="section-title px-5">
            <span class="px-2">Eventos</span>
        </p>
        <h1 class="mb-4">Próximos eventos</h1>
    </div>
    <div class="row">
        <div class="col-12 text-center mb-2">
            <ul class="list-inline mb-4 bg-white" id="portfolio-flters">
                <li class="btn btn-outline-primary m-1 active" data-filter="*">
                    Todos
                </li>
                <li class="btn btn-outline-primary m-1" data-filter=".tandil">
                    Tandil
                </li>
                <li class="btn btn-outline-primary m-1" data-filter=".juarez">
                    Benito Juárez
                </li>
                <li class="btn btn-outline-primary m-1" data-filter=".next">
                    Próximos
                </li>
            </ul>
        </div>
    </div>
    <div class="row portfolio-container ">
        @foreach($events as $event)
            <div class="col-lg-6 col-md-6 mb-4 portfolio-item {{ $event->type }}">
                <x-noticia-facebook :postId="$event->facebook_post_id"></x-noticia-facebook>
            </div>
        @endforeach
    </div>
@endsection
