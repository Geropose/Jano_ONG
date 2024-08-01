<?php

namespace App\Notifications;

use App\Models\Professional;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Http\UploadedFile;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class NewProfessional extends Notification
{
    use Queueable;

    protected Professional $professional;
    protected UploadedFile $cv;

    /**
     * Create a new notification instance.
     */
    public function __construct(Professional $prof,UploadedFile $cv)
    {
        $this->professional = $prof;
        $this->cv = $cv;
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
        $attachmentName = $this->cv->getClientOriginalName();
        return (new MailMessage)
            ->markdown('mail.profesionales', [
                'nombre' => $this->professional->name,
                'apellido' => $this->professional->surname,
                'fechaNac' => $this->professional->birth_date,
                'telefono' => $this->professional->phone,
                'ciudad' => $this->professional->city,
                'email' => $this->professional->email,
                'profesion' => $this->professional->profession,
                'capacitacion' => $this->professional->training,
                'nombreAdjunto' => $attachmentName
            ])
            ->attach($this->cv,['as'=>$attachmentName, 'mime' => $this->cv->getClientMimeType()])
            ->greeting('Nuevo Profesional creado quiere contactarse')
            ->subject('Nuevo Contacto Profesional')
            ->replyTo($this->professional->email);

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
