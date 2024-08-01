<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreFacebookNewsItemRequest;
use App\Http\Requests\UpdateFacebookNewsItemRequest;
use App\Models\FacebookNewsItem;

class FacebookNewsItemController extends Controller
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
    public function store(StoreFacebookNewsItemRequest $request)
    {
        //
    }

    /**
     * Display the specified resource.
     */
    public function show(FacebookNewsItem $facebookNewsItem)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(FacebookNewsItem $facebookNewsItem)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateFacebookNewsItemRequest $request, FacebookNewsItem $facebookNewsItem)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(FacebookNewsItem $facebookNewsItem)
    {
        //
    }
}
