<?php

namespace App\Http\Controllers;

use App\Models\FacebookNewsItem;
use App\Notifications\BussinessContactRequested;
use App\Notifications\NewContact;
use App\Notifications\NewMessage;
use App\Notifications\NewProfessional;
use App\Notifications\NewVolunteer;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Routing\Controller as BaseController;
use Illuminate\Support\Facades\Notification;


class Controller extends BaseController
{
    use AuthorizesRequests, ValidatesRequests;

    function makeContact(FormRequest $request)
    {
        Notification::route('mail', 'janoportodos@gmail.com')
            ->notify(
                new NewMessage(
                    $request->get('nombre'),
                    $request->get('email'),
                    $request->get('asunto'),
                    $request->get('mensaje')
                )
            );
    }
    function bussinessContact(FormRequest $request)
    {
        Notification::route('mail', 'janoportodos@gmail.com')
            ->notify(
                new BussinessContactRequested(
                    $request->get('nombreEmpresa'),
                    $request->get('emailEmpresa'),
                    $request->get('motivo'),
                    $request->get('propuestas'),
                    $request->get('horarioDisp')
                )
            );
    }

    function notProfessionalContact(FormRequest $request)
    {
        Notification::route('mail', 'janoportodos@gmail.com')
            ->notify(
                new NewVolunteer(
                    $request->get('nombre'),
                    $request->get('apellido'),
                    $request->get('fechaNac'),
                    $request->get('telefono'),
                    $request->get('ciudad'),
                    $request->get('email'),
                    $request->get('oficio'),
                    $request->get('area'),
                    $request->get('capacitacion')

                )
            );
    }
}
