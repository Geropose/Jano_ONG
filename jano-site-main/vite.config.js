import {defineConfig} from 'vite';
import laravel from 'laravel-vite-plugin';

import path from 'path'
import inject from "@rollup/plugin-inject";


export default defineConfig({
    plugins: [
        inject({   // => that should be first under plugins array
            $: 'jquery',
            jQuery: 'jquery',
        }),
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js'],
            refresh: true,
        })
    ],
    resolve: {
        alias: {
            '~bootstrap': path.resolve(__dirname, 'node_modules/bootstrap')

        },
    },
});
