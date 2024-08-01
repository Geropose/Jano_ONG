<!-- Modal Empresas -->
<div class="modal fade" id="ModalEmpresas" tabindex="-1" role="dialog" aria-labelledby="ModalEmpresasTitle" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="ModalEmpresasTitle">Donación de empresa</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <form formType="empresa" class="needs-validation" novalidate method="post" action="jano-contact/bussiness">
                <input type="hidden" name="formType" value="empresa">
                <input type="hidden" name="_token" value="{{ csrf_token() }}" />
                <div class="modal-body">
                    <div class="form-row">
                        <div class="form-group col-12">
                            <label for="sr-only">Nombre de la empresa</label>
                            <input type="text" class="form-control" name="nombreEmpresa" id="nombreEmpresa" required>
                            <div class="invalid-feedback">
                                Proporcione un nombre válido.
                            </div>
                        </div>
                        <div class="form-group col-12">
                            <label for="inputEmail">Email</label>
                            <input type="email" class="form-control" name="emailEmpresa" id="emailEmpresa" required>
                            <div class="invalid-feedback">
                                Proporcione un email válido.
                            </div>
                        </div>

                        <div class="form-group col-12">
                            <label for="inputMotivo">Motivo de contacto</label>
                            <input type="text" class="form-control" name="motivo" id="motivo" required>
                            <div class="invalid-feedback">
                                Proporcione un motivo válido.
                            </div>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group mb-3">
                            <label for="inputPropuestas">Propuestas de acciones de colaboración y participación</label>
                            <textarea type="text" class="form-control" name="propuestas" id="propuestas" required></textarea>
                            <div class="invalid-feedback">
                                Proporcione una propuesta válida.
                            </div>
                        </div>
                        <div class="form-group mb-3">
                            <label for="inputHorarioDisp">Días y horarios disponibles para coordinar reuniones</label>
                            <textarea type="text" class="form-control" name="horarioDisp" id="horarioDisp" required></textarea>
                            <div class="invalid-feedback">
                                Proporcione horarios válidos.
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                        <button class="btn btn-primary" type="submit">Enviar formulario</button>
                    </div>
                </div>
            </form>

        </div>
    </div>
</div>
