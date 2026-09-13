package librarysystem

import grails.plugin.springsecurity.annotation.Secured
import grails.validation.ValidationException
import org.springframework.web.multipart.MultipartFile

import static org.springframework.http.HttpStatus.NOT_FOUND

@Secured(['ROLE_ADMIN'])
class StudyRoomController {

    StudyRoomService studyRoomService

    static allowedMethods = [
            save  : 'POST',
            update: 'PUT',
            delete: 'DELETE'
    ]

    def index(Integer max) {
        params.max = Math.min(max ?: 20, 100)

        respond studyRoomService.list(params),
                model: [studyRoomCount: studyRoomService.count()]
    }

    def show(Long id) {
        StudyRoom room = studyRoomService.get(id)

        if (!room) {
            notFound()
            return
        }

        respond room
    }

    def create() {
        respond new StudyRoom()
    }

    def save() {

        StudyRoom room = new StudyRoom()

        if (!applyFormData(room)) {
            render view: 'create',
                    model: [studyRoom: room]
            return
        }

        try {

            applyImage(room)

            studyRoomService.save(room)

        } catch (ValidationException | IllegalArgumentException e) {

            flash.message =
                    e.message ?: 'تعذر إضافة الغرفة. راجع البيانات.'

            render view: 'create',
                    model: [studyRoom: room]

            return
        }

        flash.message = 'تمت إضافة غرفة الدراسة.'

        redirect action: 'show',
                id: room.id
    }

    def edit(Long id) {

        StudyRoom room = studyRoomService.get(id)

        if (!room) {
            notFound()
            return
        }

        respond room
    }

    def update(Long id) {

        StudyRoom room = studyRoomService.get(id)

        if (!room) {
            notFound()
            return
        }

        if (!applyFormData(room)) {
            render view: 'edit',
                    model: [studyRoom: room]
            return
        }

        try {

            applyImage(room)

            if (params.boolean('removeImage')) {
                room.imageData = null
                room.imageContentType = null
            }

            studyRoomService.save(room)

        } catch (ValidationException | IllegalArgumentException e) {

            flash.message =
                    e.message ?: 'تعذر تحديث الغرفة.'

            render view: 'edit',
                    model: [studyRoom: room]

            return
        }

        flash.message = 'تم تحديث الغرفة.'

        redirect action: 'show',
                id: room.id
    }

    def delete(Long id) {

        StudyRoom room = studyRoomService.get(id)

        if (!room) {
            notFound()
            return
        }

        if (RoomReservation.countByStudyRoom(room) > 0) {

            room.active = false
            studyRoomService.save(room)

            flash.message =
                    'للغرفة سجل حجوزات سابق، لذلك تم تعطيلها بدل حذفها.'

            redirect action: 'show',
                    id: id

            return
        }

        studyRoomService.delete(id)

        flash.message = 'تم حذف الغرفة.'

        redirect action: 'index'
    }

    @Secured(['ROLE_USER', 'ROLE_ADMIN'])
    def photo(Long id) {

        StudyRoom room = studyRoomService.get(id)

        if (!room?.imageData) {
            render status: NOT_FOUND
            return
        }

        response.contentType =
                room.imageContentType ?: 'image/jpeg'

        response.contentLength =
                room.imageData.length

        response.outputStream.write(
                room.imageData
        )

        response.outputStream.flush()
    }

    private boolean applyFormData(StudyRoom room) {

        /*
         * مهم:
         * لا نستخدم bindData هنا نهائياً.
         */
        room.clearErrors()

        room.roomNumber =
                params.roomNumber
                        ?.toString()
                        ?.trim()

        room.name =
                params.name
                        ?.toString()
                        ?.trim()

        room.location =
                params.location
                        ?.toString()
                        ?.trim()

        room.description =
                params.description
                        ?.toString()
                        ?.trim()

        room.features =
                params.features
                        ?.toString()
                        ?.trim()

        room.active =
                params.active?.toString() == 'true'


        /*
         * Capacity
         */
        try {

            String rawCapacity =
                    params.capacity
                            ?.toString()
                            ?.trim()

            room.capacity =
                    rawCapacity
                            ? Integer.parseInt(rawCapacity)
                            : null

        } catch (NumberFormatException ignored) {

            room.errors.rejectValue(
                    'capacity',
                    'typeMismatch',
                    'السعة يجب أن تكون رقماً صحيحاً.'
            )

            return false
        }


        /*
         * Price
         *
         * نقبل:
         * 5
         * 5.00
         * 5,00
         * 5٫00
         */
        try {

            String rawPrice =
                    params.pricePerHour
                            ?.toString()
                            ?.trim()

            if (!rawPrice) {

                room.errors.rejectValue(
                        'pricePerHour',
                        'nullable',
                        'السعر لكل ساعة مطلوب.'
                )

                return false
            }

            rawPrice = rawPrice
                    .replace('٬', '')
                    .replace('٫', '.')
                    .replace(',', '.')

            room.pricePerHour =
                    new BigDecimal(rawPrice)

        } catch (NumberFormatException ignored) {

            room.errors.rejectValue(
                    'pricePerHour',
                    'typeMismatch',
                    'السعر لكل ساعة غير صالح.'
            )

            return false
        }


        /*
         * الآن السعر صار BigDecimal فعلياً.
         * نعمل Validation بعد التحويل.
         */
        return room.validate()
    }

    private void applyImage(StudyRoom room) {

        MultipartFile file =
                request.getFile('imageFile')

        if (file && !file.empty) {

            if (!file.contentType?.startsWith('image/')) {
                throw new IllegalArgumentException(
                        'الملف يجب أن يكون صورة.'
                )
            }

            if (file.size > 5 * 1024 * 1024) {
                throw new IllegalArgumentException(
                        'حجم الصورة يجب ألا يتجاوز 5MB.'
                )
            }

            room.imageData = file.bytes
            room.imageContentType = file.contentType
        }
    }

    protected void notFound() {

        flash.message =
                'غرفة الدراسة غير موجودة.'

        redirect action: 'index'
    }
}
