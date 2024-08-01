<!-- Modal Profesionales-->
<div class="modal fade" id="ModalProfesionales" tabindex="-1" role="dialog" aria-labelledby="ModalProfesionalesTitle" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="ModalProfesionalesTitle">Voluntarios profesionales</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <form formType="profesionales" class="needs-validation" enctype="multipart/form-data" novalidate method="post" action="jano-contact/professional">
                <input type="hidden" name="formType" value="profesionales">
                <input type="hidden" name="_token" value="{{ csrf_token() }}" />
                <div class="modal-body">
                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <label for="sr-only" class="form-label">Nombre</label>
                            <input type="text" class="form-control" id="nombre" name="nombre"  required>
                            <div class="invalid-feedback">
                                Proporcione un nombre válido
                            </div>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="sr-only" class="form-label">Apellido</label>
                            <input type="text" class="form-control" id="apellido" name="apellido"  required>
                            <div class="invalid-feedback">
                                Proporcione un apellido válido
                            </div>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="inputDate">Fecha de nacimiento</label>
                            <input type="date" class="form-control" id="fechaNac" name="fechaNac" placeholder="dd/mm/yyyy" required>
                            <div class="invalid-feedback">
                                Proporcione una fecha válida.
                            </div>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="inputPhone">Telefono</label>
                            <div class="input-group">
                                <div class="input-group-text">+54</div>
                                <input type="tel" class="form-control" id="telefono" name="telefono" required pattern="[0-9]{9,10}">
                                <div class="invalid-feedback">
                                    Proporcione un telefono válido
                                </div>
                            </div>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="inputCiudad">Ciudad</label>
                            <input type="text" class="form-control" id="ciudad" name="ciudad" required>
                            <div class="invalid-feedback">
                                Proporcione una ciudad válida
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="inputEmail">Email</label>
                            <input type="email" class="form-control" id="email" name="email" required>
                            <div class="invalid-feedback">
                                Proporcione un email válido
                            </div>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <label for="inputProfesion">Profesión</label>
                            <input type="text" class="form-control" id="profesion" name="profesion" required>
                            <div class="invalid-feedback">
                                Proporcione una profesión válida
                            </div>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="inputCapacitacion">Capacitación (opcional)</label>
                            <input type="text" class="form-control" id="capacitacion" name="capacitacion" >
                        </div>
                        <div class="form-group col-md-6">
                            <label for="inputCV">Adjunte su CV</label>
                            <input type="file" class="file" id="CV" name="CV" required>
                            <div class="invalid-feedback">
                                Adjunte su CV en formato pdf y con tamaño menor a 5MB
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                    <button class="btn btn-primary" type="submit">Enviar formulario</button>
                </div>
            </form>
        </div>
    </div>
</div>
