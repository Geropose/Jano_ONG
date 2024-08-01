<?php

namespace App\View\Components;

use App\Models\FacebookNewsItem;
use Closure;
use Illuminate\Contracts\View\View;
use Illuminate\View\Component;

class UltimasNoticias extends Component
{
    /**
     * Create a new component instance.
     */
    public function __construct()
    {
        //
    }

    /**
     * Get the view / contents that represent the component.
     */
    public function render(): View|Closure|string
    {
        $news = FacebookNewsItem::all();
        return view('components.ultimas-noticias',['latestNews'=>$news]);
    }
}
