<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class BussinessContactRequested extends Notification
{
    use Queueable;

    protected $name;
    protected $email;
    protected $reason;
    protected $proposal;
    protected $schedule;

    /**
     * Create a new notification instance.
     */
    public function __construct($name, $email, $reason, $proposal, $schedule)
    {
        $this->name = $name;
        $this->email = $email;
        $this->reason = $reason;
        $this->proposal = $proposal;
        $this->schedule = $schedule;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject("Mensaje de contacto de empresa")
            ->greeting("Mensaje de contacto de empresa {$this->name}")
            ->replyTo($this->email)
            ->markdown('mail.empresas',
                [
                    'nombre' => $this->name,
                    'motivo' => $this->reason,
                    'propuestas' => $this->proposal,
                    'horarios' => $this->schedule,
                    'email' => $this->email
                ]);
    }

    /**
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        return [
            //
        ];
    }
}
