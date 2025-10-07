<?php
// app/Console/Kernel.php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    protected $commands = [
        \App\Console\Commands\FetchWildberriesData::class,
        \App\Console\Commands\CreateCompany::class,
        \App\Console\Commands\CreateAccount::class,
        \App\Console\Commands\CreateToken::class,
        \App\Console\Commands\CreateApiService::class,  // ✅ Добавлено
        \App\Console\Commands\CreateTokenType::class,   // ✅ Добавлено
    ];

    protected function schedule(Schedule $schedule)
    {
        $yesterday = now()->subDays(1)->format('Y-m-d');
        $today = now()->format('Y-m-d');

        // Продажи - дважды в день в 9:00 и 17:00
        $schedule->command("wb:fetch sales --dateFrom={$yesterday}")
            ->twiceDaily(9, 17)
            ->withoutOverlapping()
            ->appendOutputTo(storage_path('logs/scheduler.log'));

        // Заказы - дважды в день в 9:00 и 17:00
        $schedule->command("wb:fetch orders --dateFrom={$yesterday}")
            ->twiceDaily(9, 17)
            ->withoutOverlapping()
            ->appendOutputTo(storage_path('logs/scheduler.log'));

        // Поступления - дважды в день в 9:00 и 17:00
        $schedule->command("wb:fetch incomes --dateFrom={$yesterday}")
            ->twiceDaily(9, 17)
            ->withoutOverlapping()
            ->appendOutputTo(storage_path('logs/scheduler.log'));

        // Остатки - дважды в день в 9:00 и 17:00
        $schedule->command("wb:fetch stocks --dateFrom={$today}")
            ->twiceDaily(9, 17)
            ->withoutOverlapping()
            ->appendOutputTo(storage_path('logs/scheduler.log'));
    }

    protected function commands()
    {
        $this->load(__DIR__ . '/Commands');

        require base_path('routes/console.php');
    }
}
