<form formType="suscripcion" method="post" action="subscribe">
    <input type="hidden" name="formType" value="suscripcion">
    <input type="hidden" name="_token" value="{{ csrf_token() }}" />
    <div class="form-group">
        <input
            type="text"
            class="form-control border-0 py-4"
            placeholder="Nombre"
            required="required"
            name="nombre"
        />
    </div>
    <div class="form-group">
        <input
            type="email"
            class="form-control border-0 py-4"
            placeholder="Correo electrónico"
            required="required"
            name="email"
        />
    </div>
    <div>
        <button
            class="btn btn-primary btn-block border-0 py-3"
            type="submit"
        >
            Suscribite
        </button>
    </div>
</form>
