<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class NewMessage extends Notification
{
    use Queueable;

    protected $fullName;
    protected $email;
    protected $subject;
    protected $message;

    /**
     * Create a new notification instance.
     */
    public function __construct($fullName, $email, $subject, $message)
    {
        $this->fullName = $fullName;
        $this->email = $email;
        $this->subject = $subject;
        $this->message = $message;
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
            ->greeting('Nueva solicitud de contacto')
            ->line($this->message)
            ->replyTo($this->email)
            ->markdown('mail.contacto', ['nombre' => $this->fullName, 'email' => $this->email])
            ->subject($this->subject);
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
