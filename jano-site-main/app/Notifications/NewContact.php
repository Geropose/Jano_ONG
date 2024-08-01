<?php

namespace App\Notifications;

use App\Models\Contact;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class NewContact extends Notification
{
    use Queueable;

    protected Contact $contact;

    /**
     * Create a new notification instance.
     */
    public function __construct(Contact $c)
    {
        $this->contact = $c;
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
        return (new MailMessage)->greeting("Nueva Suscripcion")
                    ->subject("Nueva Suscripion a noticias")
                    ->line("Se suscribió un nuevo contacto para recibir noticias")
                    //->action('Notification Action', url('/'))
                   ->markdown('mail.suscripcion',['nombre'=>$this->contact->fullName,'email'=>$this->contact->email]);

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
