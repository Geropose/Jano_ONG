
<div class="text-center pb-2">
    <p class="section-title px-5">
        <span class="px-2">Noticias</span>
    </p>
    <h1 class="mb-4">Últimas noticias</h1>
    <div class="container-fluid pt-5">
        <div class="container pb-3">
            <div class="row">
                <div class="col-12 col-md-5 h-auto">
                    <x-noticia-facebook :postId="$latestNews[0]->facebook_post_id"/>

                </div>
                <div class="col-12 col-md-5 offset-md-1 mt-3 mt-md-0 h-auto">
                    <x-noticia-facebook :postId="$latestNews[1]->facebook_post_id"/>
                </div>
            </div>
        </div>
    </div>
</div>
