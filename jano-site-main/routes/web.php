<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/


Route::view('/', 'home');
Route::view('/home', 'home');

Route::view('/acercaDeCancerInfantoJuvenil', 'acercaDeCancerInfantoJuvenil');
Route::view('/acercaDeLegislacion', 'acercaDeLegislacion');
Route::view('/acercaDeLosDerechos', 'acercaDeLosDerechos');
Route::view('/acercaDeMasAllaDeLoMedico', 'acercaDeMasAllaDeLoMedico');
Route::view('/Nuestrahistoria', 'nuestraHistoria');
Route::view('/MisionyVision', 'misionyVision');
Route::view('/Nuestrosobjetivos', 'nuestrosObjetivos');
Route::view('/Nuestrospilares', 'nuestrosPilares');
Route::view('/quienesSomos', 'quienesSomos');
Route::view('/juntoalasfamilias', 'juntoalasFamilias');
Route::view('/Recreacionyaprendizajes', 'recreacionYAprendizajes');
Route::view('/Emprendimientos', 'emprendimientos');
Route::get('/eventos', [\App\Http\Controllers\FacebookEventItemController::class,'eventos']);

Route::view('/Equipotecnico', 'equipotecnico');
Route::view('/Voluntariado', 'voluntariado');

Route::view('/apoyanos', 'apoyanos');

Route::group(['prefix'=>'jano-contact'], function (){
    Route::post('/make', [\App\Http\Controllers\Controller::class, 'makeContact']);
    Route::post('/bussiness', [\App\Http\Controllers\Controller::class, 'bussinessContact']);
    Route::post('/professional', [\App\Http\Controllers\ProfessionalController::class, 'store']);
    Route::post('/not-professional', [\App\Http\Controllers\Controller::class, 'notProfessionalContact']);
});


Route::post('/subscribe', [\App\Http\Controllers\ContactController::class, 'store']);








