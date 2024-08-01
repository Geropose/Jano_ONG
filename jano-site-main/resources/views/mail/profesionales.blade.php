@extends('vendor.notifications.email')
@section('marked')
## Datos del profesional
**Nombre completo**
{{ $nombre }} {{ $apellido }}

**Fecha de nacimiento**
{{ $fechaNac }}

**Teléfono**
{{ $telefono }}

**Ciudad**
{{ $ciudad }}

**Email**
{{ $email }}

**Profesión**
{{ $profesion }}

**Capacitación en**
{{ $capacitacion }}

@if(!empty($nombreAdjunto))
**Nombre del archivo**
{{ $nombreAdjunto }}
@endif

@endsection
