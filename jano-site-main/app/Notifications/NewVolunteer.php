<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class NewVolunteer extends Notification
{
    use Queueable;

    protected $name, $surname,$birthDate,$phone,$city,$email,$trade,$area,$training;
    /**
     * Create a new notification instance.
     */
    public function __construct($name, $surname,$birthDate,$phone,$city,$email,$trade,$area,$training)
    {

        $this->name = $name;
        $this->surname = $surname;
        $this->birthDate = $birthDate;
        $this->phone = $phone;
        $this->city = $city;
        $this->email = $email;
        $this->trade = $trade;
        $this->area = $area;
        $this->training = $training;

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
            ->markdown('mail.no-profesionales', [
                'nombre' => $this->name,
                'apellido' => $this->surname,
                'nac' => $this->birthDate,
                'telefono' => $this->phone,
                'ciudad' => $this->city,
                'email' => $this->email,
                'oficio' => $this->trade,
                'capacitacion' => $this->training,
                'area' => $this->area
            ])
                    ->subject('Nuevo Voluntario no profesional')
                    ->greeting('Nuevo Voluntario no profesional');
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
