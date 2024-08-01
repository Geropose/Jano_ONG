@extends('vendor.notifications.email')
@section('marked')
## La empresa {{ $nombre }} se desea contactar

**debido a**

{{ $motivo }}.

**Sus propuestas son:**

{{ $propuestas }}

**Los horarios disponibles son:**

{{ $horarios }}.

**Email:** {{ $email }}

@endsection
