<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreFacebookEventItemRequest;
use App\Http\Requests\UpdateFacebookEventItemRequest;
use App\Models\FacebookEventItem;

class FacebookEventItemController extends Controller
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
    public function store(StoreFacebookEventItemRequest $request)
    {
        //
    }

    /**
     * Display the specified resource.
     */
    public function show(FacebookEventItem $facebookEventItem)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(FacebookEventItem $facebookEventItem)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateFacebookEventItemRequest $request, FacebookEventItem $facebookEventItem)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(FacebookEventItem $facebookEventItem)
    {
        //
    }

    public function eventos() {

        return view('eventos',['events'=>FacebookEventItem::all()]);
    }
}
