@extends('vendor.notifications.email')
@section('marked')
## Datos del voluntario

**Nombre completo**
{{ $nombre }} {{ $apellido }}

**Fecha de nacimiento**
{{ $nac }}

**Teléfono**
{{ $telefono }}

**Ciudad**
{{ $ciudad }}

**Email**
{{ $email }}

**Oficio**
{{ $oficio }}

**Posible área de desarrollo**
{{ $area }}

**Capacitación en**
{{ $capacitacion }}
@endsection
