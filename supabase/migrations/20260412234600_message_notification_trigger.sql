-- Trigger function to create a notification when a new message is sent
CREATE OR REPLACE FUNCTION public.handle_new_message()
RETURNS TRIGGER AS $$
DECLARE
  v_receiver_id UUID;
  v_sender_name TEXT;
BEGIN
  -- 1. Find the receiver's user_id from conversation_participants
  -- We filter by the conversation_id and exclude the sender's user_id
  SELECT user_id INTO v_receiver_id
  FROM public.conversation_participants
  WHERE conversation_id = NEW.conversation_id
    AND user_id != NEW.sender_id
  LIMIT 1;

  -- If there is no receiver (e.g. invalid chat or self-chat), silently ignore
  IF v_receiver_id IS NULL THEN
    RETURN NEW;
  END IF;

  -- 2. Look up the sender's full name from the users profile table
  SELECT full_name INTO v_sender_name
  FROM public.users
  WHERE auth_user_id = NEW.sender_id;

  -- Fallback if name is missing
  IF v_sender_name IS NULL OR v_sender_name = '' THEN
    v_sender_name := 'Someone';
  END IF;

  -- 3. Insert the notification for the receiver
  -- Because this inserts into 'notifications', your existing Database Webhook
  -- will pick this up and automatically invoke the push-notifications Edge Function! 
  INSERT INTO public.notifications (
    user_id,
    title,
    description,
    type,
    reference_id,
    related_user_id
  ) VALUES (
    v_receiver_id,
    'New Message',
    v_sender_name || ' sent you a message.',
    'message',
    NEW.conversation_id::text,
    NEW.sender_id::text
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger on the messages table
DROP TRIGGER IF EXISTS on_message_created ON public.messages;
CREATE TRIGGER on_message_created
  AFTER INSERT ON public.messages
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_message();
