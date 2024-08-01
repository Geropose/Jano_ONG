<?php

namespace Database\Seeders;

use App\Models\FacebookNewsItem;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class FacebookNewsItemSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        //
        FacebookNewsItem::factory()->create(['facebook_post_id'=>648217694015475]);
        FacebookNewsItem::factory()->create(['facebook_post_id'=>648664413970803]);
    }
}
