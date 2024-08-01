<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreProfessionalRequest;
use App\Http\Requests\UpdateProfessionalRequest;
use App\Models\Professional;
use App\Notifications\NewProfessional;
use Illuminate\Support\Facades\Notification;

class ProfessionalController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        //
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreProfessionalRequest $request)
    {
        $prof = new Professional();
        $prof->name = $request->get('nombre');
        $prof->surname = $request->get('apellido');
        $prof->birth_date = $request->get('fechaNac');
        $prof->phone = $request->get('telefono');
        $prof->city = $request->get('ciudad');
        $prof->email = $request->get('email');
        $prof->profession = $request->get('profesion');
        $prof->training = $request->get('capacitacion');
        $CV = $request->file('CV');
        if($prof->save()){
            Notification::route('mail', 'janoportodos@gmail.com')
                ->notify(
                    new NewProfessional($prof,$CV)
                );
        }

    }

    /**
     * Display the specified resource.
     */
    public function show(Professional $professional)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Professional $professional)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateProfessionalRequest $request, Professional $professional)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Professional $professional)
    {
        //
    }
}
