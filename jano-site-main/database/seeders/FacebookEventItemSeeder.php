<?php

namespace Database\Seeders;

use App\Models\FacebookEventItem;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class FacebookEventItemSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        //
        FacebookEventItem::factory()->create(['facebook_post_id'=>644258887744689,'tag'=>'tandil']);
        FacebookEventItem::factory()->create(['facebook_post_id'=>632335558937022,'tag'=>'tandil']);
        FacebookEventItem::factory()->create(['facebook_post_id'=>2564870846986434,'tag'=>'tandil']);

        FacebookEventItem::factory()->create(['facebook_post_id'=>627728559397722,'tag'=>'juarez']);
    }
}
