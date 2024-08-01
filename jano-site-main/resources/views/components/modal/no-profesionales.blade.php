<!-- Modal NoProfesionales-->
<div class="modal fade" id="ModalNoProfesionales" tabindex="-1" role="dialog" aria-labelledby="ModalNoProfesionalesTitle" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="ModalNoProfesionalesTitle">Voluntarios</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
            <form formType= "no profesionales" class="needs-validation" id="not-professional" novalidate method="post" action="jano-contact/not-professional">
                <input type="hidden" name="_token" value="{{ csrf_token() }}" />

                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <label for="sr-only">Nombre</label>
                            <input type="text" class="form-control" id="nombre" required>
                            <div class="invalid-feedback">
                                Proporcione un nombre válido.
                            </div>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="sr-only">Apellido</label>
                            <input type="text" class="form-control" id="apellido" required>
                            <div class="invalid-feedback">
                                Proporcione un nombre válido.
                            </div>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="inputDate">Fecha de nacimiento</label>
                            <input type="datatime-local" class="form-control" id="fechaNac" placeholder="dd/mm/yyyy" required>
                            <div class="invalid-feedback">
                                Proporcione una fecha válida.
                            </div>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="inputPhone">Telefono</label>
                            <div class="input-group">
                                <div class="input-group-text">+54</div>
                                <input type="tel"class="form-control" id="telefono" required pattern="[0-9]{9,10}">
                                <div class="invalid-feedback">
                                    Proporcione un telefono válido.
                                </div>
                            </div>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="inputCiudad">Ciudad</label>
                            <input type="text" class="form-control" id="ciudad" required>
                            <div class="invalid-feedback">
                                Proporcione una ciudad válida.
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="inputEmail">Email</label>
                        <input type="email" class="form-control" id="email" required>
                        <div class="invalid-feedback">
                            Proporcione un email válido.
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <label for="inputOficio">Oficio</label>
                            <input type="text" class="form-control" id="oficio" required>
                            <div class="invalid-feedback">
                                Proporcione un oficio válido.
                            </div>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="area">Área de posible desarrollo</label>
                            <select id="area" class="form-control" required>
                                <option value="">Seleccionar...</option>
                                <option>Comunicación</option>
                                <option>Eventos</option>
                                <option>Donaciones</option>
                                <option>Mantenimiento y acondicionamiento de sede</option>
                                <option>Otros</option>
                            </select>
                            <div class="invalid-feedback">Seleccione una opción válida</div>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="inputCapacitacion">Capacitación en especialidad (opcional)</label>
                            <input type="text" class="form-control" id="capacitacion">
                        </div>
                    </div>
            </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" form="not-professional" data-dismiss="modal">Cerrar</button>
                    <button class="btn btn-primary" type="submit" form="not-professional">Enviar formulario</button>
                </div>

        </div>
    </div>
</div>
