<div class="text-center pb-2">
    <p class="section-title px-5">
        <span class="px-2">Mantente en contacto</span>
    </p>
    <h1 class="mb-4">Contactanos para resolver cualquier duda</h1>

    <div class="row p-3 bg-light">
        <div class="col-lg-7 mb-5">
            <div class="contact-form">
                <div id="success"></div>
                <form class="needs-validation" novalidate method="post" action="jano-contact/make">
                    <input type="hidden" name="_token" value="{{ csrf_token() }}" />
                    <input type="hidden" name="formType" value="contacto">
                    <div class="control-group">
                        <input
                            type="text"
                            class="form-control"
                            id="nombre"
                            name="nombre"
                            placeholder="Nombre y apellido"
                            required="required"
                            data-validation-required-message="Por favor ingresa tu nombre y apellido"
                        />
                        <p class="help-block text-danger"></p>
                    </div>
                    <div class="control-group">
                        <input
                            type="email"
                            name="email"
                            class="form-control"
                            id="email"
                            placeholder="Email"
                            required="required"
                            data-validation-required-message="Por favor ingresa tu email"
                        />
                        <p class="help-block text-danger"></p>
                    </div>
                    <div class="control-group">
                        <input
                            type="text"
                            class="form-control"
                            id="asunto"
                            name="asunto"
                            placeholder="Asunto"
                            required="required"
                            data-validation-required-message="Por favor ingresa un asunto"
                        />
                        <p class="help-block text-danger"></p>
                    </div>
                    <div class="control-group">
                  <textarea
                      class="form-control"
                      rows="6"
                      id="mensaje"
                      name="mensaje"
                      placeholder="Mensaje"
                      required="required"
                      data-validation-required-message="Por favor ingresa tu mensaje"
                  ></textarea>
                        <p class="help-block text-danger"></p>
                    </div>
                    <div>
                        <button
                            class="btn btn-primary py-2 px-4"
                            type="submit"
                            id="sendMessageButton"
                        >
                            Enviar mensaje
                        </button>
                    </div>
                </form>
            </div>
        </div>
        <div class="col-lg-5 mb-5">
            <!-- <div class="d-flex">
              <i
                class="fa fa-map-marker-alt d-inline-flex align-items-center justify-content-center bg-primary text-secondary rounded-circle"
                style="width: 45px; height: 45px"
              ></i>
              <div class="pl-3">
                <h5>Dirección</h5>
                <p>Moreno 1064, Tandil, Bs As</p>
              </div>
            </div> -->
            <div class="d-flex">
                <i
                    class="fa fa-envelope d-inline-flex align-items-center justify-content-center bg-primary text-secondary rounded-circle"
                    style="width: 45px; height: 45px"
                ></i>
                <div class="pl-3">
                    <h5>Email</h5>
                    <p>janoportodos@gmail.com</p>
                </div>
            </div>
            <div class="d-flex">
                <i
                    class="fa fa-phone-alt d-inline-flex align-items-center justify-content-center bg-primary text-secondary rounded-circle"
                    style="width: 45px; height: 45px"
                ></i>
                <div class="pl-3">
                    <h5>Teléfono</h5>
                    <p>+54 2494635221</p>
                </div>
            </div>
            <div class="d-flex">
                <i
                    class="far fa-clock d-inline-flex align-items-center justify-content-center bg-primary text-secondary rounded-circle"
                    style="width: 45px; height: 45px"
                ></i>
                <div class="pl-3">
                    <h5>Horario</h5>
                    <strong>Lunes - Sábado:</strong>
                    <p class="m-0">08:00 AM - 05:00 PM</p>
                </div>
            </div>
        </div>
    </div>
</div>
